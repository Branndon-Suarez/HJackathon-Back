module Webhooks
  class N8nController < ApplicationController
    skip_before_action :authenticate_request!
    include Shared::SignatureVerification

    # GET /webhooks/n8n — verificación de conectividad (opcional)
    def verify
      head :ok
    end

    # POST /webhooks/n8n
    # Endpoint para recibir resultados del chatbot de n8n.
    #
    # Payload esperado (formato plano):
    # {
    #   "session_id": "abc-123",
    #   "timestamp": "2026-05-11T15:30:00Z",
    #   "confianza_datos": "alta",
    #   "confianza_metricas": "media",
    #   "lead_nombre": "Juan Pérez",
    #   "lead_correo": "juan@empresa.com",
    #   "...": "..."
    # }
    #
    # Filtra por session_id para vincular con el diagnostic existente.
    def receive
      payload = JSON.parse(request.body.read)
      @sections = Reports::PayloadParser.parse(payload)

      Rails.logger.info(
        "[N8nWebhook] session_id=#{@sections[:session_id]} " \
        "confianza_datos=#{@sections[:confianza_datos]} " \
        "confianza_metricas=#{@sections[:confianza_metricas]}"
      )

      result = Reports::GenerateService.new(payload).call

      render json: {
        success: true,
        report_id: result.id,
        data: ReportSerializer.render_as_hash(result, view: :extended)
      }, status: :created
    rescue ArgumentError, ActiveRecord::RecordNotFound => e
      Rails.logger.warn("[N8nWebhook] #{e.class}: #{e.message} (session_id=#{@sections&.fetch(:session_id, 'unknown')})")
      render json: {
        success: false,
        error: { code: "NOT_FOUND", message: e.message }
      }, status: :unprocessable_entity
    rescue JSON::ParserError => e
      Rails.logger.error("[N8nWebhook] Invalid JSON: #{e.message}")
      render json: {
        success: false,
        error: { code: "INVALID_JSON", message: "El body no es JSON válido" }
      }, status: :bad_request
    rescue StandardError => e
      Rails.logger.error("[N8nWebhook] #{e.class}: #{e.message}")
      Rails.logger.error(e.backtrace&.first(10)&.join("\n"))
      render json: {
        success: false,
        error: {
          code: "PROCESSING_ERROR",
          message: "Error al procesar el reporte desde n8n",
          detail: Rails.env.development? ? e.message : nil
        }
      }, status: :internal_server_error
    end
  end
end