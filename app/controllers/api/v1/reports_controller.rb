module Api
  module V1
    class ReportsController < ApplicationController
      before_action :set_report, only: %i[show download_pdf]

      # GET /api/v1/reports
      # Lista los informes del lead actual (o todos si es admin).
      def index
        reports = current_lead.reports.processed.ordered
          .includes(:diagnostic)
          .page(params[:page]).per(params[:per] || 10)

        render json: {
          data: ReportSerializer.render_as_hash(reports, view: :extended),
          meta: pagination_meta(reports)
        }
      end

      # GET /api/v1/reports/:id
      def show
        authorize_report!(@report)
        render json: {
          data: ReportSerializer.render_as_hash(@report, view: :extended)
        }
      end

      # GET /api/v1/reports/:id/download_pdf
      def download_pdf
        authorize_report!(@report)
        pdf = PdfReportService.new(@report).generate
        send_data pdf, filename: "audit_report_#{@report.id}.pdf",
                       type: "application/pdf",
                       disposition: "attachment"
      end

      # GET /api/v1/reports/latest
      # Último informe del lead actual.
      def latest
        report = current_lead.reports.processed.ordered.first
        return head :not_found unless report

        render json: {
          data: ReportSerializer.render_as_hash(report, view: :extended)
        }
      end

      private

      def set_report
        if params[:session_id].present?
          @report = ProcessedReportQuery.new(params[:session_id]).call
        else
          @report = Report.find(params[:id])
        end
      end

      def authorize_report!(report)
        # Verifica que el report pertenezca al lead actual
        unless current_lead.reports.exists?(report.id)
          raise JsonWebToken::AuthError, "No autorizado para ver este reporte"
        end
      end
    end
  end
end