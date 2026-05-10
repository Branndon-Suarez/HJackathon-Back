module Diagnostics
  class ProcessService
    def initialize(diagnostic)
      @diagnostic = diagnostic
    end

    def call
      ActiveRecord::Base.transaction do
        @diagnostic.update!(status: :processing)

        Diagnostics::CalculateFitScoreService.new(@diagnostic).call

        @diagnostic.update!(status: :completed)

        notify_n8n
      end

      @diagnostic
    rescue StandardError => e
      @diagnostic.update!(status: :failed)
      Rails.logger.error("[Diagnostics::ProcessService] Failed: #{e.message}")
      raise
    end

    private

    def notify_n8n
      N8nWebhookJob.perform_later(@diagnostic.id)
    end
  end
end
