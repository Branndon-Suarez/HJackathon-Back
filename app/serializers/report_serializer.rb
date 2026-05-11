class ReportSerializer < Blueprinter::Base
  identifier :id

  fields :report_type, :overall_score, :recommendation,
         :processed, :error_message, :created_at, :updated_at

  # Solo se exponen scoring y datos cuando el reporte fue procesado
  view :default do
    field :scoring do |report|
      report.scoring if report.processed?
    end
  end

  view :extended do
    field :scoring do |report|
      report.scoring if report.processed?
    end

    field :resumen_diagnostico do |report|
      next unless report.processed?
      rd = report.raw_data || {}

      {
        # Info del lead
        lead: {
          nombre: rd["lead_nombre"],
          correo: rd["lead_correo"],
          empresa: rd["lead_empresa"],
          sector: rd["lead_sector"],
          canal_digital: rd["lead_canal_digital"]
        },
        # Info del negocio
        negocio: {
          que_vende: rd["negocio_que_vende"],
          a_quien: rd["negocio_a_quien"],
          etapa: rd["negocio_etapa"],
          tiempo_operando: rd["negocio_tiempo_operando"],
          tamano_equipo: rd["negocio_tamano_equipo"]
        },
        # Datos de sesión
        session_id: rd["session_id"],
        timestamp: rd["timestamp"],
        confianza_datos: rd["confianza_datos"],
        confianza_metricas: rd["confianza_metricas"],
        datos_faltantes: rd["datos_faltantes"]
      }
    end

    field :metricas_financieras do |report|
      next unless report.processed?
      report.scoring&.dig("metricas_financieras") || report.scoring&.dig("financial_metrics_summary")
    end

    field :analisis_canal do |report|
      next unless report.processed?
      report.scoring&.dig("breakdown", "canal")
    end

    field :analisis_cac do |report|
      next unless report.processed?
      report.scoring&.dig("breakdown", "cac")
    end

    field :analisis_valor do |report|
      next unless report.processed?
      report.scoring&.dig("breakdown", "valor")
    end

    field :prioridades do |report|
      next unless report.processed?
      report.scoring&.dig("breakdown", "prioridades")
    end

    field :plan_mejora do |report|
      next unless report.processed?
      report.scoring&.dig("breakdown", "plan_mejora")
    end

    field :quick_wins do |report|
      next unless report.processed?
      report.scoring&.dig("breakdown", "quick_wins")
    end

    field :customer_journey do |report|
      next unless report.processed?
      report.scoring&.dig("breakdown", "customer_journey")
    end

    field :fit_decision do |report|
      next unless report.processed?
      rd = report.raw_data || {}
      {
        nivel_fit: rd["fit_nivel_fit"],
        estado_lead: rd["fit_estado_lead"],
        decision_final: rd["fit_decision_final"],
        servicio_recomendado: rd["fit_servicio_recomendado"],
        razon_decision: rd["fit_razon_decision"],
        ticket_potencial: rd["fit_ticket_potencial"],
        probabilidad_conversion: rd["fit_probabilidad_conversion"],
        siguiente_accion: rd["fit_siguiente_accion"],
        mensaje_follow_up: rd["fit_mensaje_follow_up_interno"],
        objeciones_probables: rd["fit_objeciones_probables"],
        datos_faltantes_fit: rd["fit_datos_faltantes"]
      }
    end

    field :sintetizador do |report|
      next unless report.processed?
      rd = report.raw_data || {}
      {
        titulo: rd["dx0_titulo"],
        fecha: rd["dx0_fecha"],
        reporte_texto: rd["dx0_reporte_texto"],
        resumen_ejecutivo: rd["dx0_resumen_ejecutivo"],
        cta_texto: rd["dx0_cta_texto"],
        cta_tipo: rd["dx0_cta_tipo"]
      }
    end

    field :salud_comercial do |report|
      next unless report.processed?
      report.raw_data&.dig("salud_comercial")
    end

    field :alertas do |report|
      next unless report.processed?
      report.raw_data&.dig("alerta_lista")
    end

    association :diagnostic, blueprint: DiagnosticSerializer
  end
end