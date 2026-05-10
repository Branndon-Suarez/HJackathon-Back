module RiBuzz
  class ScoringService
    SCORING_RULES = {
      stage: { label: "Etapa del negocio", weight: 1 },
      problem: { label: "Problema", weight: 2 },
      solution: { label: "Solución", weight: 2 },
      icp: { label: "ICP", weight: 2 },
      current_client: { label: "Cliente actual", weight: 1 },
      offer: { label: "Oferta", weight: 3 },
      value_equation: { label: "Ecuación de valor", weight: 2 },
      ticket: { label: "Ticket medio", weight: 2 },
      recurrence: { label: "Recurrencia", weight: 2 },
      main_channel: { label: "Canal principal de adquisición", weight: 2 },
      cac: { label: "CAC", weight: 2 },
      conversion: { label: "Conversión", weight: 3 },
      follow_up: { label: "Seguimiento", weight: 2 },
      scaling: { label: "Escalamiento", weight: 2 },
      execution_capacity: { label: "Capacidad de ejecución", weight: 1 }
    }.freeze

    def initialize(commercial_inputs)
      @inputs = commercial_inputs.with_indifferent_access
      @variables = @inputs.dig(:commercial_variables) || {}
    end

    def call
      scores = SCORING_RULES.map do |key, rule|
        score = send("score_#{key}")
        {
          variable: rule[:label],
          score: score,
          estado: estado(score),
          weight: rule[:weight]
        }
      end

      {
        scores: scores,
        weighted_average: weighted_average(scores),
        overall_state: overall_state(weighted_average(scores))
      }
    end

    private

    def estado(score)
      case score
      when 1 then "critico"
      when 2 then "debil"
      when 3 then "funcional"
      when 4 then "fuerte"
      when 5 then "escalable"
      else "desconocido"
      end
    end

    def weighted_average(scores)
      total_weight = scores.sum { |s| s[:weight] }
      return 0 if total_weight.zero?

      (scores.sum { |s| s[:score] * s[:weight] }.to_f / total_weight).round(1)
    end

    def overall_state(average)
      case average
      when 1..1.9 then "critico"
      when 2..2.9 then "debil"
      when 3..3.9 then "funcional"
      when 4..4.9 then "fuerte"
      when 5 then "escalable"
      else "desconocido"
      end
    end

    # --- Individual scoring methods ---

    def score_stage
      stage = @inputs.dig(:business_context, :etapa_actual).to_s.downcase
      case stage
      when "transformacion", "crecimiento" then 4
      when "operacion" then 3
      when "validacion" then 2
      when "idea" then 1
      else 2
      end
    end

    def score_problem
      problem = @variables.dig(:problema) || {}
      return 1 if problem[:problema_que_resuelve].blank?

      urgency = problem[:urgencia_del_problema].to_s.downcase
      case urgency
      when "alta" then 4
      when "media" then 3
      when "baja" then 2
      else 2
      end
    end

    def score_solution
      solution = @variables.dig(:solucion) || {}
      return 1 if solution[:descripcion_solucion].blank?

      has_diff = solution[:diferenciador].present?
      has_evidence = solution[:evidencia_de_resultado].present?

      score = 2
      score += 1 if has_diff
      score += 1 if has_evidence
      [ score, 5 ].min
    end

    def score_icp
      client = @variables.dig(:cliente) || {}
      return 1 if client[:cliente_ideal_actual].blank?

      has_decisor = client[:decisor_de_compra].present?
      has_dolores = client[:dolores_del_cliente].presence

      score = 2
      score += 1 if has_decisor
      score += 1 if has_dolores&.any?
      [ score, 5 ].min
    end

    def score_current_client
      client = @variables.dig(:cliente) || {}
      return 1 if client[:cliente_que_ya_compra].blank?

      has_best = client[:mejor_cliente_observado].present?
      has_no_fit = client[:cliente_no_fit].present?

      score = 2
      score += 1 if has_best
      score += 1 if has_no_fit
      [ score, 5 ].min
    end

    def score_offer
      offer = @variables.dig(:oferta) || {}
      return 1 if offer[:oferta_actual].blank?

      clarity = offer[:nivel_claridad_oferta].to_s.downcase
      base = case clarity
      when "alto" then 4
      when "medio" then 3
      when "bajo" then 2
      else 2
      end

      base += 1 if offer[:promesa_principal].present?
      base -= 1 if offer[:objeciones_frecuentes].presence&.size&.>= 3
      [ base, 5 ].min.clamp(1, 5)
    end

    def score_value_equation
      eq = @variables.dig(:ecuacion_valor_hormozi) || {}
      return 1 if eq[:resultado_sonado].blank?

      score = 2
      score += 1 if eq[:palanca_mas_debil].present?
      score += 1 if eq[:probabilidad_percibida_de_logro].to_s.downcase == "alta"
      [ score, 5 ].min
    end

    def score_ticket
      monetization = @variables.dig(:monetizacion) || {}
      ticket = monetization[:ticket_medio].to_s
      return 1 if ticket.blank?

      numeric = ticket.gsub(/[^0-9.]/, "").to_f
      if numeric >= 1000 then 4
      elsif numeric >= 200 then 3
      elsif numeric >= 50 then 2
      else 2
      end
    end

    def score_recurrence
      monetization = @variables.dig(:monetizacion) || {}
      recurrence = monetization[:recurrencia].to_s.downcase

      case recurrence
      when "suscripcion", "contrato" then 5
      when "mantenimiento", "recompra" then 4
      when "referidos" then 3
      when "ninguna" then 1
      else 2
      end
    end

    def score_main_channel
      acquisition = @variables.dig(:adquisicion) || {}
      channel = acquisition[:canal_principal_adquisicion] || {}

      scalability = channel[:escalabilidad].to_s.downcase
      case scalability
      when "alta" then 4
      when "media" then 3
      when "baja" then 2
      else 2
      end
    end

    def score_cac
      cac_data = @variables.dig(:cac) || {}
      known = cac_data[:cac_conocido].to_s.downcase

      case known
      when "si" then 4
      when "estimado" then 3
      when "no" then 1
      else 1
      end
    end

    def score_conversion
      conversion = @variables.dig(:conversion) || {}
      rate = conversion[:conversion_aproximada].to_s.gsub(/[^0-9.]/, "").to_f

      if rate >= 20 then 4
      elsif rate >= 10 then 3
      elsif rate >= 5 then 2
      elsif rate > 0 then 2
      else 1
      end
    end

    def score_follow_up
      follow = @variables.dig(:seguimiento) || {}
      crm = follow[:uso_crm_o_base_de_datos].to_s.downcase

      case crm
      when "si" then 4
      when "parcial" then 3
      when "no" then 1
      else 1
      end
    end

    def score_scaling
      scaling = @variables.dig(:escalamiento) || {}
      dependency = scaling[:dependencia_del_fundador].to_s.downcase

      case dependency
      when "baja" then 4
      when "media" then 3
      when "alta" then 1
      else 2
      end
    end

    def score_execution_capacity
      execution = @variables.dig(:ejecucion) || {}
      capacity = execution[:capacidad_de_ejecucion].to_s.downcase

      case capacity
      when "alta" then 4
      when "media" then 3
      when "baja" then 2
      else 2
      end
    end
  end
end
