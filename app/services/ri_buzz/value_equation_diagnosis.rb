module RiBuzz
  class ValueEquationDiagnosis
    def initialize(commercial_inputs)
      @inputs = commercial_inputs.with_indifferent_access
      @eq = @inputs.dig(:commercial_variables, :ecuacion_valor_hormozi) || {}
    end

    def call
      {
        resultado_sonado: analyze_dream_result,
        probabilidad_percibida_de_logro: analyze_perceived_probability,
        tiempo_hasta_resultado: analyze_time_to_result,
        esfuerzo_y_sacrificio: analyze_effort,
        palanca_prioritaria: find_priority_lever,
        diagnostico_general: build_general_diagnosis,
        recomendacion_oferta: build_offer_recommendation
      }
    end

    private

    def analyze_dream_result
      return { estado: "debil", diagnostico: "No se identificó un resultado soñado claro" } if @eq[:resultado_sonado].blank?

      text = @eq[:resultado_sonado].to_s
      if text.length > 20
        { estado: "claro", diagnostico: "El resultado soñado está definido con claridad" }
      else
        { estado: "confuso", diagnostico: "El resultado soñado es muy genérico, necesita especificidad" }
      end
    end

    def analyze_perceived_probability
      prob = @eq[:probabilidad_percibida_de_logro].to_s.downcase
      has_evidence = @eq[:evidencia_de_resultado].present?

      case prob
      when "alta" then { estado: "alta", diagnostico: "El cliente confía en que el resultado es alcanzable" }
      when "media"
        if has_evidence
          { estado: "media", diagnostico: "Credibilidad media, pero la evidencia ayuda" }
        else
          { estado: "media", diagnostico: "Credibilidad media. Falta evidencia para aumentar confianza" }
        end
      when "baja" then { estado: "baja", diagnostico: "Baja credibilidad. Se necesita prueba social, casos o garantías" }
      else { estado: "media", diagnostico: "No se pudo determinar la credibilidad percibida" }
      end
    end

    def analyze_time_to_result
      time = @eq[:tiempo_hasta_resultado].to_s.downcase

      case time
      when /inmediat|1 día|2 día|3 día|semana/i then { estado: "corto", diagnostico: "El tiempo hasta resultado es atractivo" }
      when /mes|30 día|60 día/i then { estado: "medio", diagnostico: "Tiempo razonable. Acelerar con quick wins" }
      when /año|6 mes|12 mes/i then { estado: "largo", diagnostico: "Tiempo largo. Segmentar en hitos cortos" }
      else { estado: "indefinido", diagnostico: "No hay claridad sobre el tiempo para ver resultados" }
      end
    end

    def analyze_effort
      effort = @eq[:esfuerzo_y_sacrificio_requerido].to_s.downcase

      case effort
      when /bajo|mínimo|cero|nulo/i then { estado: "bajo", diagnostico: "Baja fricción para el cliente" }
      when /medio|moderado|algo/i then { estado: "medio", diagnostico: "Esfuerzo medio. Reducir pasos para mejorar conversión" }
      when /alto|mucho|complejo|difícil/i then { estado: "alto", diagnostico: "Alta fricción. Simplificar la experiencia de compra" }
      else { estado: "medio", diagnostico: "No se pudo determinar el nivel de esfuerzo requerido" }
      end
    end

    def find_priority_lever
      priorities = []

      priorities << "resultado_sonado" if @eq[:resultado_sonado].blank? || @eq[:resultado_sonado].to_s.length <= 20
      priorities << "probabilidad" if @eq[:evidencia_de_resultado].blank?
      priorities << "tiempo" if @eq[:tiempo_hasta_resultado].to_s.match?(/año|6 mes/i)
      priorities << "esfuerzo" if @eq[:esfuerzo_y_sacrificio_requerido].to_s.match?(/alto|complejo/i)

      priorities.any? ? priorities.first : "resultado_sonado"
    end

    def build_general_diagnosis
      dream = analyze_dream_result[:estado]
      prob = analyze_perceived_probability[:estado]
      time = analyze_time_to_result[:estado]
      effort = analyze_effort[:estado]

      if dream == "claro" && prob == "alta" && time == "corto" && effort == "bajo"
        "La ecuación de valor está equilibrada. La oferta comunica resultado, es creíble, rápida y de baja fricción."
      else
        debilidades = []
        debilidades << "el resultado soñado no está claro" if dream != "claro"
        debilidades << "la credibilidad es #{prob}" if prob != "alta"
        debilidades << "el tiempo es #{time}" if time != "corto"
        debilidades << "el esfuerzo es #{effort}" if effort != "bajo"
        "La oferta tiene debilidades: #{debilidades.join(', ')}. Priorizar fortalecer la palanca más débil."
      end
    end

    def build_offer_recommendation
      lever = find_priority_lever
      case lever
      when "resultado_sonado"
        "Definir el resultado concreto que el cliente obtendrá, en lenguaje del cliente y medible."
      when "probabilidad"
        "Agregar casos de éxito, testimonios, garantía, datos o demostración que aumenten la credibilidad."
      when "tiempo"
        "Rediseñar la oferta para mostrar un avance rápido. Quick win + resultado completo."
      when "esfuerzo"
        "Simplificar la compra e implementación. Reducir pasos, automatizar entrega."
      end
    end
  end
end
