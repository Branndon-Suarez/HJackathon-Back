module Reports
  # Orquesta la generación de un report a partir del payload plano de n8n.
  #
  # Flujo:
  # 1. Localiza el diagnostic por session_id
  # 2. Almacena raw_data completo
  # 3. Ejecuta scoring
  # 4. Persiste report
  # 5. Retorna el report procesado
  class GenerateService
    def initialize(n8n_payload)
      @sections = PayloadParser.parse(n8n_payload)
    end

    def call
      diagnostic = find_diagnostic

      # Idempotencia: si ya existe un report procesado, devolverlo
      if diagnostic.report&.processed?
        Rails.logger.info("[Reports::GenerateService] Report already processed for session_id=#{session_id} diagnostic_id=#{diagnostic.id}")
        return diagnostic.report
      end

      report = create_or_update_report(diagnostic)
      process_report(report)
      report
    end

    private

    def session_id
      @sections[:session_id]
    end

    def find_diagnostic
      raise ArgumentError, "session_id is required in n8n payload" if session_id.blank?

      diagnostic = Diagnostic.find_by(session_id: session_id)
      raise ActiveRecord::RecordNotFound, "No diagnostic found for session_id=#{session_id}" unless diagnostic

      diagnostic
    end

    def create_or_update_report(diagnostic)
      report = diagnostic.report || diagnostic.build_report
      report.report_type = "n8n_diagnostic"
      report.raw_data = @sections[:raw]
      report.save!
      report
    end

    def process_report(report)
      scoring_result = ScoringService.new(report.raw_data).call

      report.update!(
        scoring: scoring_result,
        overall_score: scoring_result[:overall_label],
        recommendation: scoring_result[:recommendation],
        processed: true
      )
    rescue StandardError => e
      report.update!(
        error_message: "#{e.class}: #{e.message}",
        processed: false
      )
      Rails.logger.error("[Reports::GenerateService] #{e.message}\n#{e.backtrace&.first(5)&.join("\n")}")
      raise
    end
  end
end