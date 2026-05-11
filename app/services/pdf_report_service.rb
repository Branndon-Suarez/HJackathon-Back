class PdfReportService
  def initialize(report)
    @report = report
    @diagnostic = report.diagnostic
    @lead = @diagnostic.lead
    @company = @lead.company
    @scoring = report.scoring || {}
    @raw = report.raw_data || {}
  end

  def generate
    pdf = Prawn::Document.new(page_size: "A4", margin: [50, 50, 50, 50])

    header(pdf)
    pdf.move_down 30

    company_info(pdf)
    pdf.move_down 20

    fit_score_section(pdf)
    pdf.move_down 20

    if @diagnostic.commercial_outputs.present?
      health_summary(pdf)
      pdf.move_down 20
    end

    recommendation_section(pdf)

    pdf.page_count.times do |i|
      pdf.go_to_page(i + 1)
      pdf.draw_text "RiBuzz Audit Report - #{Date.current}", size: 8, at: [40, 20], color: "666666"
      pdf.draw_text "Page #{i + 1} of #{pdf.page_count}", size: 8, at: [pdf.bounds.width - 60, 20], color: "666666"
    end

    pdf.render
  end

  private

  def header(pdf)
    pdf.fill_color "E625FF"
    pdf.font_size(28) { pdf.text "RiBuzz", style: :bold }
    pdf.fill_color "333333"
    pdf.font_size(10) { pdf.text "Commercial Audit Report", color: "666666" }
    pdf.stroke_horizontal_rule
  end

  def company_info(pdf)
    pdf.font_size(14) { pdf.text "Company Information", style: :bold }
    pdf.move_down 8
    pdf.font_size(10) do
      pdf.text "Company: #{@company.name}"
      pdf.text "Industry: #{@company.industry || 'N/A'}"
      pdf.text "Stage: #{@company.stage || 'N/A'}"
      pdf.text "Lead: #{@lead.full_name}"
      pdf.text "Email: #{@lead.email}"
      pdf.text "Report Date: #{@report.created_at&.strftime('%B %d, %Y') || Date.current}"
    end
  end

  def fit_score_section(pdf)
    score = @diagnostic.fit_score || 0
    percentage = [(score.to_f / 20 * 100).round, 100].min

    pdf.font_size(14) { pdf.text "Fit Score", style: :bold }
    pdf.move_down 8
    pdf.font_size(10) do
      pdf.text "Score: #{score}/20 (#{percentage}%)"
    end
  end

  def health_summary(pdf)
    outputs = @diagnostic.commercial_outputs
    scoring = outputs["scoring_variables"] || []
    scores = scoring.each_with_object({}) { |s, h| h[s["variable"]] = s["score"] }

    pdf.font_size(14) { pdf.text "Commercial Health Summary", style: :bold }
    pdf.move_down 8

    data = [["Variable", "Score", "Status"]]
    scores.each do |var, sc|
      status = sc <= 2 ? "Critical" : sc <= 3 ? "At Risk" : "Healthy"
      data << [var, sc.to_s, status]
    end

    pdf.font_size(9) do
      pdf.table(data, header: true, row_colors: ["F0F0F0", "FFFFFF"],
                width: pdf.bounds.width) do
        row(0).font_style = :bold
        row(0).background_color = "E625FF"
        row(0).text_color = "FFFFFF"
        columns(0).width = 200
        columns(1).width = 80
        columns(2).width = 120
      end
    end
  end

  def recommendation_section(pdf)
    recommendation = @report.recommendation || @raw["fit_decision_final"]
    return unless recommendation

    pdf.font_size(14) { pdf.text "Recommendation", style: :bold }
    pdf.move_down 8
    pdf.font_size(10) { pdf.text recommendation }
  end
end
