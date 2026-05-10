module RiBuzz
  class CacDiagnosis
    def initialize(commercial_inputs)
      @inputs = commercial_inputs.with_indifferent_access
      @cac_data = @inputs.dig(:commercial_variables, :cac) || {}
      @monetization = @inputs.dig(:commercial_variables, :monetizacion) || {}
    end

    def call
      estimated_cac = calculate_cac
      ticket = parse_number(@monetization[:ticket_medio])
      ltv = parse_number(@monetization[:ltv_estimado])
      recurrence = @monetization[:recurrencia].to_s.downcase

      {
        cac_estimado: estimated_cac,
        cac_conocido: @cac_data[:cac_conocido].to_s.downcase,
        confianza_dato: confidence_level,
        lectura: build_reading(estimated_cac, ticket),
        riesgo: build_risk(estimated_cac, ticket, ltv, recurrence),
        relacion_ticket_cac: ticket_cac_ratio(estimated_cac, ticket),
        relacion_cac_ltv: cac_ltv_ratio(estimated_cac, ltv),
        recomendacion: build_recommendation(estimated_cac, ticket),
        prioridad: build_priority(estimated_cac, ticket)
      }
    end

    private

    def calculate_cac
      return @cac_data[:cac_valor].to_s.gsub(/[^0-9.]/, "").to_f if @cac_data[:cac_valor].present?

      total_cost = [
        parse_number(@cac_data[:costo_pauta]),
        parse_number(@cac_data[:costo_herramientas_comerciales]),
        parse_number(@cac_data[:costo_equipo_comercial]),
        parse_number(@cac_data[:costo_contenido_o_agencia]),
        parse_number(@cac_data[:costo_comisiones]),
        parse_number(@cac_data[:otros_costos_adquisicion])
      ].sum

      new_clients = parse_number(@cac_data[:nuevos_clientes_periodo])
      return 0 if new_clients <= 0 || total_cost <= 0

      (total_cost.to_f / new_clients).round
    end

    def parse_number(value)
      value.to_s.gsub(/[^0-9.]/, "").to_f
    end

    def confidence_level
      known = @cac_data[:cac_conocido].to_s.downcase
      case known
      when "si" then "alta"
      when "estimado" then "media"
      when "no" then "baja"
      else "baja"
      end
    end

    def build_reading(cac, ticket)
      return "No se pudo estimar el CAC con los datos proporcionados" if cac <= 0 || ticket <= 0

      ratio = ticket_cac_ratio(cac, ticket)
      case ratio
      when 0..1 then "El CAC es alto en relación al ticket. Cada cliente cuesta más de lo que paga inicialmente."
      when 1..3 then "El CAC está dentro de rangos ajustados. Hay margen pero requiere monitoreo."
      else "El CAC es saludable. El ticket cubre ampliamente el costo de adquisición."
      end
    end

    def ticket_cac_ratio(cac, ticket)
      return 0 if cac <= 0
      (ticket.to_f / cac).round(2)
    end

    def cac_ltv_ratio(cac, ltv)
      return nil if cac <= 0 || ltv <= 0
      (ltv.to_f / cac).round(2)
    end

    def build_risk(cac, ticket, ltv, recurrence)
      risks = []
      risks << "CAC no conocido" if @cac_data[:cac_conocido].to_s.downcase == "no"
      risks << "CAC supera el ticket inicial" if cac > 0 && ticket > 0 && cac > ticket
      risks << "No hay recurrencia para recuperar CAC" if %w[suscripcion contrato mantenimiento recompra].none? { |r| recurrence.include?(r) }
      risks << "No hay LTV para evaluar retorno" if ltv <= 0

      risks.any? ? "Riesgos: #{risks.join(', ')}." : "Riesgo controlado."
    end

    def build_recommendation(cac, ticket)
      if cac <= 0
        "Medir el CAC durante los próximos 3 meses como métrica prioritaria."
      elsif cac > 0 && ticket > 0 && cac > ticket
        "Reducir CAC o aumentar ticket. Evaluar canales más rentables y optimizar conversión."
      elsif cac > 0 && ticket > 0 && ticket / cac < 3
        "Mejorar la relación ticket/CAC aumentando ticket medio o reduciendo costos de adquisición."
      else
        "Mantener métricas actuales. Monitorear CAC mensualmente."
      end
    end

    def build_priority(cac, ticket)
      return "critica" if cac <= 0
      return "critica" if cac > 0 && ticket > 0 && cac >= ticket
      return "alta" if cac > 0 && ticket > 0 && ticket / cac < 3
      "media"
    end
  end
end
