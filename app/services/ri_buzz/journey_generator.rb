module RiBuzz
  class JourneyGenerator
    STAGES = %w[Atraccion Interes Diagnostico Oferta Seguimiento Cierre Entrega Recurrencia].freeze

    def initialize(scoring_result, commercial_inputs)
      @scoring = scoring_result
      @inputs = commercial_inputs.with_indifferent_access
      @scores_by_variable = @scoring[:scores].index_by { |s| s[:variable] }
    end

    def call
      STAGES.each_with_index.map { |stage, i| build_stage(stage, i + 1) }
    end

    private

    def build_stage(stage, order)
      {
        etapa: stage,
        objetivo: objective(stage),
        accion_cliente: client_action(stage),
        accion_empresa: company_action(stage),
        activo_necesario: asset(stage),
        metrica: metric(stage),
        fuga_potencial: leak(stage)
      }
    end

    def objective(stage)
      objectives = {
        "Atraccion" => "Generar tráfico calificado hacia el embudo comercial",
        "Interes" => "Capturar leads y despertar interés en la solución",
        "Diagnostico" => "Calificar al lead y entender su problema específico",
        "Oferta" => "Presentar solución personalizada con valor claro",
        "Seguimiento" => "Mantener contacto y resolver objeciones",
        "Cierre" => "Convertir el lead en cliente",
        "Entrega" => "Cumplir la promesa y generar primera experiencia positiva",
        "Recurrencia" => "Mantener relación comercial y generar recompra o referido"
      }
      objectives[stage]
    end

    def client_action(stage)
      actions = {
        "Atraccion" => "Descubre la empresa a través de un canal",
        "Interes" => "Solicita información o descarga contenido",
        "Diagnostico" => "Responde preguntas y comparte su situación",
        "Oferta" => "Evalúa la propuesta y compara alternativas",
        "Seguimiento" => "Responde o ignora los intentos de contacto",
        "Cierre" => "Toma decisión de compra o rechaza",
        "Entrega" => "Recibe e implementa la solución",
        "Recurrencia" => "Vuelve a comprar o recomienda"
      }
      actions[stage]
    end

    def company_action(stage)
      actions = {
        "Atraccion" => "Publicar contenido, pautar, hacer outreach en canal principal",
        "Interes" => "Enviar lead magnet, agendar llamada de diagnóstico",
        "Diagnostico" => "Aplicar diagnóstico comercial RiBuzz",
        "Oferta" => "Preparar propuesta personalizada con precio y entregables",
        "Seguimiento" => "Ejecutar secuencia de seguimiento multicanal",
        "Cierre" => "Resolver objeciones, presentar garantía, cerrar",
        "Entrega" => "Onboarding, activación y soporte inicial",
        "Recurrencia" => "Programa de fidelización, upsell, solicitar referido"
      }
      actions[stage]
    end

    def asset(stage)
      assets = {
        "Atraccion" => "Contenido, pauta, perfil en redes",
        "Interes" => "Lead magnet, landing page, formulario",
        "Diagnostico" => "Cuestionario, llamada, herramienta de diagnóstico",
        "Oferta" => "Propuesta comercial, cotización, demo",
        "Seguimiento" => "CRM, email, WhatsApp, calendario",
        "Cierre" => "Contrato, factura, medio de pago",
        "Entrega" => "Plataforma, onboarding, materiales",
        "Recurrencia" => "Programa de referidos, email marketing, comunidad"
      }
      assets[stage]
    end

    def metric(stage)
      metrics = {
        "Atraccion" => "Impresiones, clics, tráfico",
        "Interes" => "Leads capturados, tasa de conversión a lead",
        "Diagnostico" => "Leads calificados, tasa de avance",
        "Oferta" => "Propuestas enviadas, tasa de apertura",
        "Seguimiento" => "Tasa de respuesta, tiempo promedio",
        "Cierre" => "Tasa de cierre, ticket promedio",
        "Entrega" => "Tasa de activación, NPS inicial",
        "Recurrencia" => "Tasa de recompra, referidos generados"
      }
      metrics[stage]
    end

    def leak(stage)
      score = score_for_stage(stage)

      leaks = {
        "Atraccion" => "Bajo volumen o tráfico no calificado",
        "Interes" => "Oferta débil o sin lead magnet",
        "Diagnostico" => "Calificación manual lenta o inexistente",
        "Oferta" => "Propuesta genérica o sin valor claro",
        "Seguimiento" => "Sin proceso de seguimiento o CRM",
        "Cierre" => "Objeciones no resueltas, precio sin justificar",
        "Entrega" => "Onboarding débil, abandono temprano",
        "Recurrencia" => "Sin programa de recompra ni referidos"
      }

      leak_text = leaks[stage]
      leak_text += " (riesgo alto)" if score && score <= 2
      leak_text
    end

    def score_for_stage(stage)
      mapping = {
        "Atraccion" => "Canal principal de adquisición",
        "Interes" => "Problema",
        "Diagnostico" => "ICP",
        "Oferta" => "Oferta",
        "Seguimiento" => "Seguimiento",
        "Cierre" => "Conversión",
        "Entrega" => "Solución",
        "Recurrencia" => "Recurrencia"
      }
      var_name = mapping[stage]
      @scores_by_variable[var_name]&.dig(:score)
    end
  end
end
