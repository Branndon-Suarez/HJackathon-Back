class ProcessedReportQuery
  # Busca un report procesado por session_id.
  # Permite al frontend hacer:
  #   GET /api/v1/reports?session_id=abc-123
  # en vez de conocer el ID interno del report.
  def initialize(session_id)
    @session_id = session_id
  end

  def call
    report = Report.processed.joins(:diagnostic)
      .where(diagnostics: { session_id: @session_id })
      .first

    raise ActiveRecord::RecordNotFound, "No processed report found for session_id=#{@session_id}" unless report

    report
  end
end