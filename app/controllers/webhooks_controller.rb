class WebhooksController < ApplicationController
  skip_before_action :authenticate_request!
  skip_before_action :verify_authenticity_token, raise: false

  def n8n
    puts "IDs disponibles: #{Diagnostic.pluck(:id)}"
    @diagnostic = Diagnostic.find(params[:diagnostic_id])

    # Aquí es donde ocurre la magia: llamamos a tu ProcessWebhookService
    # Pasamos params.to_unsafe_h porque n8n manda llaves que no están en tu schema
    if N8n::ProcessWebhookService.call(@diagnostic, params.to_unsafe_h)
      render json: { message: "Webhook procesado y plan generado con éxito" }, status: :ok
    else
      render json: { error: "Error al procesar los datos de n8n" }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Diagnostic no encontrado" }, status: :not_found
  end
end