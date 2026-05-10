module RiBuzz
  class DiagnosticService
    def initialize(diagnostic)
      @diagnostic = diagnostic
      @inputs = diagnostic.commercial_inputs || {}
    end

    def call
      ActiveRecord::Base.transaction do
        @diagnostic.update!(status: :processing)

        scoring = RiBuzz::ScoringService.new(@inputs).call
        general_diagnosis = build_general_diagnosis(scoring)
        decision = RiBuzz::DecisionEngine.new(@inputs, scoring, general_diagnosis).call

        outputs = build_full_outputs(scoring, general_diagnosis, decision)

        @diagnostic.update!(
          commercial_outputs: outputs,
          fit_score: (scoring[:weighted_average] * 20).round,
          critical_pain: find_critical_pain(scoring),
          status: :completed
        )

        @diagnostic
      end
    rescue StandardError => e
      @diagnostic.update!(status: :failed)
      Rails.logger.error("[RiBuzz::DiagnosticService] #{e.message}")
      raise
    end

    private

    def build_full_outputs(scoring, general_diagnosis, decision)
      scoring_with_diagnosis = enrich_scores_with_diagnosis(scoring)

      {
        diagnostico_usuario: general_diagnosis,
        scoring_variables: scoring_with_diagnosis,
        diagnostico_ecuacion_valor: RiBuzz::ValueEquationDiagnosis.new(@inputs).call,
        diagnostico_canal_adquisicion: RiBuzz::ChannelDiagnosis.new(@inputs).call,
        diagnostico_cac: RiBuzz::CacDiagnosis.new(@inputs).call,
        top_3_prioridades: RiBuzz::PriorityEngine.new(scoring, @inputs).call,
        plan_mejora: RiBuzz::ImprovementPlanGenerator.new(scoring, @inputs).call,
        customer_journey: RiBuzz::JourneyGenerator.new(scoring, @inputs).call,
        output_comercial_interno: build_internal_commercial(decision),
        recomendacion_oferta_ribuzz: build_offer_recommendation(decision),
        decision_final: {
          decision: decision[:recommended_service],
          razon: decision[:reason],
          proxima_accion: decision[:next_action],
          mensaje_sugerido: build_suggested_message(general_diagnosis, decision)
        }
      }
    end

    def enrich_scores_with_diagnosis(scoring)
      scoring[:scores].map do |s|
        s.merge(
          diagnostico: score_diagnosis(s[:variable], s[:score]),
          impacto: score_impact(s[:variable], s[:score]),
          prioridad: score_priority(s[:score]),
          accion_recomendada: score_action(s[:variable])
        )
      end
    end

    def score_diagnosis(variable, score)
      case score
      when 1 then "#{variable} en estado crítico. Bloquea ventas directamente."
      when 2 then "#{variable} es débil. Genera fricción en el sistema comercial."
      when 3 then "#{variable} es funcional pero no escala bien."
      when 4 then "#{variable} es fuerte y aporta al crecimiento."
      when 5 then "#{variable} es escalable. Claro, medible y replicable."
      else "Sin diagnóstico disponible."
      end
    end

    def score_impact(variable, score)
      return "Bloquea ventas" if score <= 2
      return "Genera fricción" if score == 3
      "Impulsa crecimiento"
    end

    def score_priority(score)
      return "alta" if score <= 2
      return "media" if score == 3
      "baja"
    end

    def score_action(variable)
      RiBuzz::ImprovementPlanGenerator.new(@scoring || @diagnostic, @inputs)
        .send(:build_initial_action, variable)
    rescue StandardError
      "Diagnosticar y mejorar #{variable.downcase}"
    end

    def build_general_diagnosis(scoring)
      context = @inputs.dig(:business_context, :descripcion_empresa) || "Sin descripción"
      root_cause = find_root_cause(scoring)

      {
        contexto_empresa: context,
        diagnostico_general: generate_summary(scoring),
        causa_raiz: root_cause,
        resumen_en_una_frase: generate_one_liner(scoring, root_cause),
        nivel_madurez_comercial: scoring[:overall_state]
      }
    end

    def find_root_cause(scoring)
      worst = scoring[:scores].min_by { |s| s[:score] }
      return "No identificada" unless worst

      if worst[:score] == 1
        "#{worst[:variable]} está en estado crítico y bloqueando ventas directamente"
      else
        "#{worst[:variable]} es el punto más débil del sistema comercial"
      end
    end

    def find_critical_pain(scoring)
      worst = scoring[:scores].min_by { |s| s[:score] }
      worst ? worst[:variable] : nil
    end

    def generate_summary(scoring)
      state = scoring[:overall_state]
      average = scoring[:weighted_average]

      case state
      when "critico", "debil"
        "El sistema comercial presenta deficiencias estructurales. " \
          "Score ponderado: #{average}/5. Se requiere intervención prioritaria."
      when "funcional"
        "El sistema comercial opera pero no escala. " \
          "Score ponderado: #{average}/5. Hay oportunidades claras de mejora."
      when "fuerte", "escalable"
        "El sistema comercial tiene una base sólida. " \
          "Score ponderado: #{average}/5. Las mejoras serán incrementales."
      else
        "No se pudo generar un diagnóstico completo."
      end
    end

    def generate_one_liner(scoring, root_cause)
      company = @inputs.dig(:lead, :empresa) || "Tu empresa"
      "#{company} tiene un sistema comercial #{scoring[:overall_state]}. #{root_cause}"
    end

    def build_internal_commercial(decision)
      fit = decision[:fit]
      {
        lead_score: (decision[:fit][:score].to_f / 7 * 100).round,
        nivel_fit: fit[:level],
        nivel_confianza_fit: decision[:nivel_confianza_fit],
        estado_lead: lead_status(fit[:level], decision[:probability]),
        dolor_principal: @diagnostic.critical_pain,
        urgencia: urgency_level,
        capacidad_pago_estimado: estimated_payment_capacity,
        coachability: decision[:fit][:level] == "no_fit" ? "baja" : "media",
        fit_marketing_tecnologia: marketing_tech_fit,
        servicio_recomendado_ribuzz: decision[:recommended_service],
        razon_servicio_recomendado: decision[:reason],
        ticket_potencial: estimate_ticket,
        probabilidad_conversion: decision[:probability],
        siguiente_accion_comercial: decision[:next_action]
      }
    end

    def lead_status(fit_level, probability)
      return "no_fit" if fit_level == "no_fit"
      return "estrategico" if fit_level == "estrategico" || probability == "alta"
      return "caliente" if probability == "alta"
      return "tibio" if probability == "media"
      "nuevo"
    end

    def urgency_level
      input_fit = @inputs.dig(:fit_ribuzz, :urgencia).to_s.downcase
      return input_fit if %w[alta media baja].include?(input_fit)

      problem = @inputs.dig(:commercial_variables, :problema, :urgencia_del_problema).to_s.downcase
      return problem if %w[alta media baja].include?(problem)
      "media"
    end

    def estimated_payment_capacity
      input_fit = @inputs.dig(:fit_ribuzz, :willingness_to_pay).to_s.downcase
      return input_fit if %w[alta media baja].include?(input_fit)

      ticket = @inputs.dig(:commercial_variables, :monetizacion, :ticket_medio).to_s.gsub(/[^0-9.]/, "").to_f
      return "alta" if ticket >= 500
      return "media" if ticket >= 100
      "baja"
    end

    def marketing_tech_fit
      input_fit = @inputs.dig(:fit_ribuzz, :fit_marketing_tecnologia).to_s.downcase
      return input_fit if %w[alto medio bajo].include?(input_fit)

      tools = @inputs.dig(:commercial_variables, :ejecucion, :herramientas_actuales)
      tools.present? && tools.any? ? "medio" : "bajo"
    end

    def estimate_ticket
      ticket = @inputs.dig(:commercial_variables, :monetizacion, :ticket_medio).to_s
      return ticket if ticket.present?

      monthly = @inputs.dig(:commercial_variables, :monetizacion, :ventas_mensuales_aproximadas).to_s
      clients = @inputs.dig(:commercial_variables, :monetizacion, :numero_clientes_actuales).to_s
      return "$#{monthly.to_f / clients.to_f}" if monthly.present? && clients.present? && clients.to_f > 0
      "No disponible"
    end

    def build_offer_recommendation(decision)
      service = decision[:recommended_service]
      case service
      when "autoservicio"
        { oferta_recomendada: "Autoservicio",
          justificacion: "Bajo ticket, baja urgencia o baja capacidad de pago",
          entregables_sugeridos: [ "Diagnóstico completo descargable", "Guía de acción priorizada" ],
          condiciones_para_avanzar: [ "Ejecutar plan de mejora autogestionado" ] }
      when "diagnostico_premium"
        { oferta_recomendada: "Diagnóstico Premium",
          justificacion: "Dolor presente pero falta claridad antes de proponer",
          entregables_sugeridos: [ "Sesión de diagnóstico profundo", "Informe ejecutivo", "Recomendación personalizada" ],
          condiciones_para_avanzar: [ "Agendar llamada de 45 min" ] }
      when "diseno_sistema_comercial"
        { oferta_recomendada: "Diseño de Sistema Comercial",
          justificacion: "Ya vende pero no tiene estructura clara",
          entregables_sugeridos: [ "Diagnóstico completo", "Diseño de pipeline comercial", "KPIs y OKRs", "Customer journey" ],
          condiciones_para_avanzar: [ "Presentar propuesta y agendar sesión de diseño" ] }
      when "implementacion"
        { oferta_recomendada: "Implementación",
          justificacion: "Necesita activos concretos: CRM, automatización, contenido",
          entregables_sugeridos: [ "CRM configurado", "Automatizaciones", "Contenido comercial" ],
          upsell_potencial: [ "Growth partner post-implementación" ],
          condiciones_para_avanzar: [ "Definir alcance y presupuesto" ] }
      when "growth_partner"
        { oferta_recomendada: "Growth Partner",
          justificacion: "Operación activa con potencial de crecimiento",
          entregables_sugeridos: [ "Acompañamiento mensual", "Ejecución comercial", "Optimización continua" ],
          upsell_potencial: [ "Escalamiento a equipo dedicado" ],
          condiciones_para_avanzar: [ "Agendar reunión ejecutiva" ] }
      else
        { oferta_recomendada: "No Fit",
          justificacion: "No cumple condiciones mínimas para trabajar con RiBuzz",
          entregables_sugeridos: [ "Recursos gratuitos", "Guía de validación inicial" ],
          condiciones_para_avanzar: [ "Validar modelo de negocio", "Generar primeras ventas" ] }
      end
    end

    def build_suggested_message(general_diagnosis, decision)
      company = @inputs.dig(:lead, :empresa) || "Tu empresa"
      pain = general_diagnosis[:causa_raiz]

      case decision[:recommended_service]
      when "no_fit"
        "Hemos analizado #{company}. Por ahora no tenemos un servicio ajustado a tu etapa actual, " \
          "pero te compartimos recursos gratuitos para avanzar."
      when "autoservicio"
        "El diagnóstico de #{company} está listo. Puedes descargar tu plan de mejora y empezar a ejecutarlo."
      when "diagnostico_premium"
        "#{company} tiene potencial, pero necesitamos entender mejor tu situación. " \
          "Agendemos una sesión de diagnóstico para profundizar."
      when "diseno_sistema_comercial"
        "#{company} ya vende, pero identificamos que #{pain}. " \
          "El siguiente paso es diseñar un sistema comercial estructurado. Te presentamos una propuesta."
      when "implementacion"
        "El diagnóstico muestra que #{company} necesita activos comerciales concretos. " \
          "Podemos implementarlos juntos. #{pain} es el punto de partida."
      when "growth_partner"
        "#{company} tiene una base sólida y oportunidad de acelerar. " \
          "Como Growth Partner podemos ejecutar contigo las mejoras priorizadas. " \
          "Agendemos una reunión para definir el plan."
      else
        "Gracias por completar el diagnóstico de #{company}. Te contactaremos con los resultados."
      end
    end
  end
end
