module Reports
  # Conversión recursiva de string keys a indifferent access.
  # Necesario porque raw_data se guarda como string keys en el DB.
  module DeepIndifferentAccess
    def self.call(hash)
      case hash
      when Hash
        new_hash = ActiveSupport::HashWithIndifferentAccess.new
        hash.each { |k, v| new_hash[k] = call(v) }
        new_hash
      when Array
        hash.map { |v| call(v) }
      else
        hash
      end
    end
  end

  # Parses the flat n8n webhook payload into structured sections.
  # All n8n keys are top-level (e.g. "lead_nombre", "comercial_problema").
  # IMPORTANT: more specific patterns MUST come before generic ones.
  module PayloadParser
    SECTIONS = {
      dx_prioridad:  /^dx_prioridad_\d_/,  # must be before /^dx_/
      dx0:           /^dx0_/,               # must be before /^dx_/
      lead:          /^lead_/,
      negocio:       /^negocio_/,
      comercial:     /^comercial_/,
      objetivo:      /^objetivo_/,
      metrica:       /^metrica_/,
      scoring:       /^scoring_/,
      dx:            /^dx_/,
      fit:           /^fit_/,
      alerta:        /^alerta_/,
      dato_faltante: /^datos_faltantes$/
    }.freeze

    def self.parse(raw)
      raw = raw.with_indifferent_access if raw.is_a?(Hash) && !raw.is_a?(ActiveSupport::HashWithIndifferentAccess)
      sections = {}
      raw.each do |key, value|
        section = classify_key(key.to_s)
        next unless section

        sections[section] ||= {}
        short_key = key.to_s.sub(/^(#{sections[section][:prefix]})/, "")
        sections[section][short_key] = value
      end
      sections[:raw] = raw.to_h.deep_stringify_keys
      sections[:timestamp]         = raw[:timestamp]
      sections[:session_id]        = raw[:session_id]
      sections[:confianza_datos]   = raw[:confianza_datos]
      sections[:confianza_metricas] = raw[:confianza_metricas]
      sections[:datos_faltantes]   = raw[:datos_faltantes]
      sections[:alertas]           = raw[:alerta_lista]
      sections[:salud_comercial]   = raw[:salud_comercial]
      sections
    end

    private

    def self.classify_key(key)
      SECTIONS.each do |section, regex|
        return section if regex.match?(key)
      end
      nil
    end
  end

  # Calcula scoring de un informe a partir del payload plano de n8n.
  class ScoringService
    CATEGORY_WEIGHTS = {
      mercado:   0.15,
      dolor:     0.20,
      oferta:    0.15,
      cliente:   0.15,
      metricas:  0.20,
      canal:     0.10,
      madurez:   0.05
    }.freeze

    EXCELLENT = 8.0
    GOOD      = 6.5
    MODERATE  = 4.5
    POOR      = 2.5

    def initialize(n8n_payload)
      parsed = n8n_payload.is_a?(String) ? JSON.parse(n8n_payload) : n8n_payload
      deep_indifferent = DeepIndifferentAccess.call(parsed)
      @sections  = PayloadParser.parse(deep_indifferent)
      @scoring   = @sections[:scoring] || {}
      @metricas  = @sections[:metrica] || {}
      @comercial = @sections[:comercial] || {}
    end

    def call
      n8n_avg   = extract_n8n_average
      synthetic = compute_synthetic_score
      overall   = n8n_avg || synthetic

      {
        score_promedio_n8n:  n8n_avg,
        score_sintetico:     synthetic,
        overall_score:       overall.round(1),
        overall_label:       classify_score(overall),
        nivel_madurez:       @scoring[:nivel_madurez_comercial],
        causa_raiz:          @scoring[:causa_raiz],
        variables_criticas:  parse_critical_vars,
        recomendacion:       extract_recommendation,
        confidence:          compute_confidence,
        breakdown:           build_breakdown,
        metricas_financieras: financial_metrics_summary
      }
    end

    private

    def extract_n8n_average
      avg = @scoring[:score_promedio]
      return nil if avg.nil? || avg.to_s.strip.empty?
      avg.to_f
    end

    def compute_synthetic_score
      scores = {}

      etapa = (@sections.dig(:negocio, :etapa) || "").downcase
      scores[:mercado] = case etapa
        when "crecimiento", "escala", "scale-up" then 4
        when "validacion", "validacion"      then 3
        when "operacion", "operacion"        then 3
        when "idea", "seed"                  then 1
        else 2
      end

      problema  = @comercial[:problema].to_s
      impacto   = @comercial[:problema_impacto].to_s
      scores[:dolor] = if problema.blank?
        1
      elsif impacto.include?("alto") || impacto.include?("critico")
        4
      elsif impacto.include?("medio")
        3
      else
        2
      end

      oferta       = @comercial[:oferta].to_s
      diferenciador = @comercial[:diferenciador].to_s
      resultado     = @comercial[:resultado_prometido].to_s
      scores[:oferta] = if oferta.blank?
        1
      else
        base = 2
        base += 1 if diferenciador.present?
        base += 1 if resultado.present?
        [base, 5].min
      end

      cliente_real  = @comercial[:cliente_real].to_s
      cliente_icp   = @comercial[:cliente_icp].to_s
      decisor        = @comercial[:decisor].to_s
      scores[:cliente] = if cliente_real.blank? && cliente_icp.blank?
        1
      else
        base = 2
        base += 1 if decisor.present?
        base += 1 if cliente_real.present? && cliente_icp.present?
        [base, 5].min
      end

      ticket     = @metricas[:ticket_medio].to_s.gsub(/[^0-9.]/, "").to_f
      conversion = @comercial[:tasa_conversion].to_s.gsub(/[^0-9.]/, "").to_f
      cac        = @metricas[:cac].to_s
      ltv        = @metricas[:ltv].to_s

      metrica_score = 0
      metrica_score += (ticket >= 1000 ? 4 : ticket >= 300 ? 3 : ticket > 0 ? 2 : 1)
      metrica_score += (conversion >= 20 ? 3 : conversion >= 10 ? 2 : conversion > 0 ? 1 : 0)
      metrica_score += (cac.present? && cac != "no" ? 2 : 1)
      metrica_score += (ltv.present? ? 2 : 1)
      scores[:metricas] = [metrica_score / 4.0, 5].min.round(1)

      canal = (@sections.dig(:dx, :canal_principal) || @comercial[:canal_principal] || "").to_s
      previsibilidad = @comercial[:canal_previsibilidad].to_s.downcase
      escalabilidad  = (@sections.dig(:dx, :canal_escalabilidad) || "").to_s.downcase
      scores[:canal] = if canal.blank?
        1
      else
        base = 2
        base += 1 if previsibilidad.include?("alta")
        base += 1 if escalabilidad.include?("alta")
        [base, 5].min
      end

      madurez = @scoring[:nivel_madurez_comercial].to_s.downcase
      scores[:madurez] = case madurez
        when "maduro", "avanzado", "alto"     then 5
        when "intermedio", "medio"            then 3
        when "inicial", "bajo", "primerizo"   then 1
        else 2
      end

      total_weight = CATEGORY_WEIGHTS.values.sum
      weighted = scores.sum { |k, v| (v || 0) * (CATEGORY_WEIGHTS[k] || 0) }
      (weighted / total_weight).round(1)
    end

    def classify_score(score)
      if score >= EXCELLENT then "excellent"
      elsif score >= GOOD then "good"
      elsif score >= MODERATE then "moderate"
      elsif score >= POOR then "poor"
      else "critical"
      end
    end

    def parse_critical_vars
      raw = @scoring[:variables_criticas]
      case raw
      when Hash then raw
      when String then safe_parse(raw)
      when Array then raw
      else raw.to_s
      end
    end

    def extract_recommendation
      if @scoring[:servicio_recomendado].present?
        map_recommendation(@scoring[:servicio_recomendado])
      elsif @scoring[:decision_final].present?
        map_recommendation(@scoring[:decision_final])
      elsif @sections.dig(:fit, :servicio_recomendado).present?
        map_recommendation(@sections.dig(:fit, :servicio_recomendado))
      elsif @sections.dig(:fit, :decision_final).present?
        map_recommendation(@sections.dig(:fit, :decision_final))
      else
        label = classify_score(extract_n8n_average || compute_synthetic_score)
        default_recommendation(label)
      end
    end

    def map_recommendation(raw)
      case raw.to_s.downcase
      when /growth_partner|partner/, /socio estrategico/ then "growth_partner"
      when /implementacion/, /implement/              then "implementacion"
      when /diagnostico_premium|premium/, /diagnostico premium/ then "diagnostico_premium"
      when /autoservicio|self.serve/, /auto.servicio/  then "autoservicio"
      when /no_fit|no fit/, /descartar/                then "no_fit"
      else raw.to_s
      end
    end

    def default_recommendation(label)
      case label
      when "excellent", "good"     then "growth_partner"
      when "moderate"              then "implementacion"
      when "poor"                  then "diagnostico_premium"
      else "autoservicio"
      end
    end

    def compute_confidence
      filled = @scoring.reject { |_, v| v.nil? || v.to_s.strip.empty? }
      total = @scoring.size
      total.zero? ? 0 : ((filled.size.to_f / total) * 100).round
    end

    def build_breakdown
      {
        mercado:      @sections[:negocio]&.slice(:etapa, :tiempo_operando, :tamano_equipo),
        dolor:        @comercial.slice(:problema, :problema_impacto),
        oferta:       @comercial.slice(:oferta, :diferenciador, :resultado_prometido, :cta),
        cliente:      @comercial.slice(:cliente_real, :cliente_icp, :decisor),
        objeciones:   @comercial[:objeciones],
        presupuesto:  @comercial[:presupuesto],
        dependencia_fundador: @comercial[:dependencia_fundador],
        seguimiento:   @comercial[:seguimiento_proceso],
        herramientas:  @comercial[:herramientas],
        canal:        (@sections.dig(:dx, :canal_principal) || @comercial[:canal_principal] || "").to_s,
        canal_detalle: @sections[:dx]&.slice(:canal_dependencia, :canal_previsibilidad, :canal_escalabilidad),
        cac:          @sections[:dx]&.slice(:cac_estimado, :cac_lectura, :cac_relacion_ticket, :cac_relacion_ltv, :cac_prioridad),
        valor:        @sections[:dx]&.slice(
          :valor_resultado_sonado_estado, :valor_resultado_sonado_dx,
          :valor_probabilidad_estado, :valor_probabilidad_dx,
          :valor_tiempo_estado, :valor_tiempo_dx,
          :valor_esfuerzo_estado, :valor_esfuerzo_dx,
          :valor_palanca_prioritaria, :valor_recomendacion_oferta
        ),
        prioridades:    extract_prioridades,
        quick_wins:      @sections[:plan_quick_wins],
        customer_journey: @sections[:plan_customer_journey],
        plan_mejora:     @sections[:plan_mejora]
      }
    end

    def extract_prioridades
      (1..3).map do |i|
        p = @sections[:dx_prioridad]
        next nil unless p
        {
          posicion:  i,
          variable:  p["prioridad_#{i}_variable"],
          razon:     p["prioridad_#{i}_razon"],
          impacto:   p["prioridad_#{i}_impacto"],
          metrica:   p["prioridad_#{i}_metrica"]
        }
      end.compact
    end

    def financial_metrics_summary
      {
        ticket_medio: @metricas[:ticket_medio],
        cac:          @metricas[:cac],
        ltv:          @metricas[:ltv],
        factor_recurrencia:       @metricas[:factor_recurrencia],
        ratio_cac_ticket:         @metricas[:ratio_cac_ticket],
        ratio_cac_ltv:            @metricas[:ratio_cac_ltv],
        leads_perdidos:           @metricas[:leads_perdidos],
        ingreso_potencial:        @metricas[:ingreso_potencial],
        inversion_mes:            @comercial[:inversion_mes],
        leads_mes:                @comercial[:leads_mes],
        ventas_mes:               @comercial[:ventas_mes],
        clientes_actuales:        @comercial[:clientes_actuales],
        clientes_nuevos_mes:      @comercial[:clientes_nuevos_mes],
        recurrencia:              @comercial[:recurrencia]
      }
    end

    def safe_parse(str)
      JSON.parse(str)
    rescue JSON::ParserError
      str
    end
  end
end