module Chatbot
  # Orchestrates conversation flow: decides what to do after each message
  # Uses interpretation + conversation context to pick the right response path
  class Orchestrator
    attr_reader :conversation, :last_message

    def initialize(conversation)
      @conversation = conversation
      @last_message = conversation.messages.user_messages.last
    end

    def call
      return welcome_response if cold_start?

      interpretation = interpret
      return clarification_response(interpretation) if interpretation.needs_clarification

      handle_intent(interpretation)
    end

    private

    def cold_start?
      conversation.messages.count == 1 && @last_message.role == "user"
    end

    def interpret
      @interpretation ||= Chatbot::Interpreter.new(@last_message.content).call
    end

    def welcome_response
      {
        type: "text",
        content: "Hola 👋 Soy tu asistente de diagnóstico comercial. Puedo ayudarte a:\n\n" \
                 "• 📊 Evaluar el estado de tu negocio (scoring)\n" \
                 "• 🗺️ Diseñar tu camino de crecimiento (customer journey)\n" \
                 "• 💰 Analizar costos de adquisición (CAC/LTV)\n" \
                 "• 💵 Definir precios y propuestas de valor\n" \
                 "• 🚀 Crear un plan de mejoras\n\n" \
                 "¿Por dónde quieres empezar?",
        suggested_actions: [
          { label: "Hacer diagnóstico rápido", trigger: "diagnóstico" },
          { label: "Analizar mi negocio", trigger: "evaluar negocio" },
          { label: "Ver opciones de servicio", trigger: "servicios" }
        ]
      }
    end

    def clarification_response(interpretation)
      {
        type: "text",
        content: clarification_text(interpretation),
        type_options: clarification_options(interpretation)
      }
    end

    def clarification_text(interpretation)
      case interpretation.intent
      when :scoring then "Para hacer un diagnóstico necesito saber más sobre tu negocio. ¿En qué etapa está? (idea, validación, operación, crecimiento, transformación)"
      when :journey then "¿Ya tienes diagnóstico previo o quieres que partamos desde cero?"
      when :cac then "¿Tienes datos de cuánto gastas en marketing y cuántos clientes adquieres al mes?"
      when :pricing then "¿Me puedes contar qué vendes y a quién?"
      when :fix then "¿Puedes describirme qué está fallando o qué quieres mejorar?"
      when :help then "Puedo ayudarte con diagnóstico comercial, análisis de customer journey, cálculo de CAC/LTV y diseño de estrategias. ¿Qué necesitas?"
      else "No entendí bien. ¿Puedes reformular o elegir una de estas opciones?"
      end
    end

    def clarification_options(interpretation)
      case interpretation.intent
      when :scoring
        [{ label: "Estoy en idea", trigger: "etapa:idea" },
         { label: "Estoy validando", trigger: "etapa:validación" },
         { label: "Ya opero", trigger: "etapa:operación" },
         { label: "En crecimiento", trigger: "etapa:crecimiento" },
         { label: "En transformación", trigger: "etapa:transformación" }]
      when :help
        [{ label: "Scoring", trigger: "diagnóstico" },
         { label: "Journey", trigger: "customer journey" },
         { label: "CAC", trigger: "cac" },
         { label: "Servicios", trigger: "servicios" }]
      else
        [{ label: "Volver al inicio", trigger: "hola" }]
      end
    end

    def handle_intent(interpretation)
      case interpretation.intent
      when :scoring, :fix
        handle_scoring(interpretation)
      when :journey
        handle_journey(interpretation)
      when :cac
        handle_cac(interpretation)
      when :pricing
        handle_pricing(interpretation)
      when :onboarding
        handle_onboarding(interpretation)
      when :cancel
        handle_cancel(interpretation)
      when :help
        help_response
      else
        fallback_response(interpretation)
      end
    end

    def handle_scoring(interpretation)
      entities = interpretation.entities

      if entities[:industry].present?
        {
          type: "scoring_flow",
          step: "industry_confirmed",
          content: "Veo que trabajas en #{entities[:industry][:value]}. Perfecto.\n" \
                   "Para hacer el scoring necesito que respondas unas preguntas rápidas sobre tu negocio. " \
                   "¿Puedo iniciar tu diagnóstico?",
          actions: [
            { label: "Sí, iniciar diagnóstico", trigger: "diagnostic:start" },
            { label: "Ver qué se evalúa", trigger: "diagnostic:preview" }
          ]
        }
      else
        {
          type: "text",
          content: "Para iniciar el diagnóstico necesito saber en qué industria trabajas. " \
                   "¿A qué sector pertenece tu negocio?",
          type_options: [
            { label: "Software/SaaS", trigger: "industry:software" },
            { label: "E-commerce/Retail", trigger: "industry:ecommerce" },
            { label: "Servicios/Consultoría", trigger: "industry:servicios" },
            { label: "Otro", trigger: "industry:otro" }
          ]
        }
      end
    end

    def handle_journey(interpretation)
      {
        type: "journey_flow",
        content: "Para diseñar tu customer journey necesito entender tu situación actual. " \
                 "¿Ya tienes un diagnóstico comercial previo con nosotros o prefieres empezar desde cero?",
        actions: [
          { label: "Tengo diagnóstico previo", trigger: "journey:existing" },
          { label: "Empezar desde cero", trigger: "journey:new" }
        ]
      }
    end

    def handle_cac(interpretation)
      entities = interpretation.entities

      if entities[:ticket_range].present?
        {
          type: "cac_analysis",
          content: "Con un ticket promedio de #{format_ticket(entities[:ticket_range])} puedo analizar tus " \
                   "métricas de CAC y LTV. Para esto necesitaría:\n\n" \
                   "1. Tu inversión mensual en marketing\n" \
                   "2. Número de leads que generas al mes\n" \
                   "3. Tasa de conversión actual\n\n¿Tienes estos datos disponibles?",
          actions: [
            { label: "Sí, los tengo", trigger: "cac:input" },
            { label: "No los tengo", trigger: "cac:estimate" }
          ]
        }
      else
        {
          type: "text",
          content: "Para analizar tu CAC necesito saber tu ticket promedio. ¿Cuánto cobras promedio por cliente? " \
                   "(Puedes darme un rango como $100-$500 o un monto fijo)",
          type_options: [
            { label: "Menos de $100", trigger: "cac:ticket:micro" },
            { label: "$100 - $500", trigger: "cac:ticket:small" },
            { label: "$500 - $2000", trigger: "cac:ticket:medium" },
            { label: "Más de $2000", trigger: "cac:ticket:enterprise" }
          ]
        }
      end
    end

    def handle_pricing(interpretation)
      {
        type: "pricing_discussion",
        content: "Para ayudarte con precios necesito entender tu modelo. " \
                 "¿Vendes un producto, un servicio o una suscripción?",
        actions: [
          { label: "Producto", trigger: "pricing:product" },
          { label: "Servicio", trigger: "pricing:service" },
          { label: "Suscripción/Membresía", trigger: "pricing:subscription" }
        ]
      }
    end

    def handle_onboarding(interpretation)
      {
        type: "onboarding",
        content: "¡Genial! Para empezar necesito unos datos básicos:\n\n" \
                 "1. ¿Cómo se llama tu empresa?\n" \
                 "2. ¿En qué sector trabajas?\n" \
                 "3. ¿Cuántas personas en tu equipo?\n" \
                 "4. ¿Qué objetivo principal buscas hoy?",
        actions: [
          { label: "Empezar", trigger: "onboarding:start" }
        ]
      }
    end

    def handle_cancel(interpretation)
      {
        type: "text",
        content: "¡Hasta luego! Si necesitas volver, estoy aquí. " \
                 "Puedes retomar tu conversación en cualquier momento. 👋",
        actions: [{ label: "Volver", trigger: "hola" }]
      }
    end

    def help_response
      {
        type: "text",
        content: "Estas son las cosas que puedo hacer por ti:\n\n" \
                 "📊 **Diagnóstico** — Evalúa 15 variables de tu negocio y genera un score\n" \
                 "🗺️ **Journey** — Diseña un customer journey de 8 etapas\n" \
                 "💰 **Economía** — Analiza CAC, LTV y unit economics\n" \
                 "🛠️ **Mejoras** — Genera un plan de mejora priorizado\n" \
                 "📈 **Estrategia** — Recomienda el mejor servicio para tu nivel\n\n" \
                 "¿Qué quieres explorar?",
        type_options: [
          { label: "Diagnóstico rápido", trigger: "diagnóstico" },
          { label: "Análisis de unit economics", trigger: "cac" },
          { label: "Ver todos los servicios", trigger: "servicios" },
          { label: "Hablar con humano", trigger: "humano" }
        ]
      }
    end

    def fallback_response(interpretation)
      {
        type: "text",
        content: "No me queda claro lo que necesitas. " \
                 "Te puedo ayudar con evaluación de negocio, diagnósticos, " \
                 "análisis de clientes y estrategias de crecimiento. " \
                 "¿Quieres ver las opciones?",
        type_options: [
          { label: "Ver opciones", trigger: "help" },
          { label: "Escribir mi pregunta", trigger: "free_text" }
        ]
      }
    end

    def format_ticket(range)
      if range[:min] && range[:max]
        "$#{range[:min]}-#{range[:max]}"
      elsif range[:min]
        "$#{range[:min]}/mes"
      end
    end
  end
end