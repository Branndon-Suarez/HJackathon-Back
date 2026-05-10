module RiBuzz
  class ChannelDiagnosis
    def initialize(commercial_inputs)
      @inputs = commercial_inputs.with_indifferent_access
      @acquisition = @inputs.dig(:commercial_variables, :adquisicion) || {}
      @main = @acquisition[:canal_principal_adquisicion] || {}
    end

    def call
      {
        canal_principal: @main[:canal] || "No especificado",
        dependencia: dependency_level,
        previsibilidad: predictability_level,
        escalabilidad: scalability_level,
        calidad: quality_level,
        riesgo: build_risk,
        oportunidad: build_opportunity,
        recomendacion: build_recommendation
      }
    end

    private

    def dependency_level
      dep = @main[:nivel_dependencia].to_s.downcase
      return dep if %w[baja media alta].include?(dep)

      pct = @main[:porcentaje_aproximado_de_clientes].to_s.gsub(/[^0-9.]/, "").to_f
      if pct >= 80 then "alta"
      elsif pct >= 50 then "media"
      else "baja"
      end
    end

    def predictability_level
      pred = @main[:previsibilidad].to_s.downcase
      return pred if %w[baja media alta].include?(pred)

      has_secondary = @acquisition[:canales_secundarios].presence
      has_secondary ? "media" : "baja"
    end

    def scalability_level
      scal = @main[:escalabilidad].to_s.downcase
      return scal if %w[baja media alta].include?(scal)

      "media"
    end

    def quality_level
      qual = @main[:calidad_del_canal].to_s.downcase
      return qual if %w[baja media alta].include?(qual)

      "media"
    end

    def build_risk
      risks = []
      risks << "Dependencia alta de un solo canal" if dependency_level == "alta"
      risks << "Baja previsibilidad" if predictability_level == "baja"
      risks << "Dificultad para escalar" if scalability_level == "baja"

      if risks.any?
        "Riesgo: #{risks.join(', ')}."
      else
        "Riesgo controlado. El canal principal tiene buen balance."
      end
    end

    def build_opportunity
      best_channel = @acquisition[:canal_que_mejor_convierte]
      most_traffic = @acquisition[:canal_que_mas_clientes_trae]

      opportunities = []
      if best_channel.present? && best_channel != @main[:canal]
        opportunities << "El canal que mejor convierte es '#{best_channel}' y no es el principal"
      end
      if scalability_level == "baja"
        opportunities << "Existe oportunidad de escalar el canal principal con inversión o tecnología"
      end
      if @acquisition[:canales_probados_sin_resultado].presence
        opportunities << "Canales descartados: aprendizajes disponibles"
      end

      opportunities.any? ? opportunities.join(". ") : "Diversificar canales para reducir dependencia"
    end

    def build_recommendation
      if dependency_level == "alta"
        "Reducir dependencia del canal principal. Probar y validar al menos un canal alternativo."
      elsif scalability_level == "baja"
        "Invertir en escalabilidad del canal: automatización, pauta o equipo dedicado."
      elsif predictability_level == "baja"
        "Implementar medición y trazabilidad para hacer predecible la adquisición."
      else
        "Mantener y optimizar el canal principal. Explorar canales secundarios con mejor conversión."
      end
    end
  end
end
