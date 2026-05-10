class N8nWebhookJob < ApplicationJob
  queue_as :default

  def perform(diagnostic_id)
    diagnostic = Diagnostic.find(diagnostic_id)
    webhook_url = ENV["N8N_WEBHOOK_URL"]
    return unless webhook_url.present?

    payload = DiagnosticSerializer.render(diagnostic, view: :extended)
    HttpClient.post(webhook_url, body: payload, headers: { "Content-Type" => "application/json" })
  end
end
