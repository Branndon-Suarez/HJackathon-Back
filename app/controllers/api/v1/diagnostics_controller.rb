module Api
  module V1
    class DiagnosticsController < ApplicationController
      rescue_from InvalidTransitionError do |e|
        render json: {
          error: {
            code: ErrorCodes::CONFLICT,
            message: e.message,
            status: 422,
            details: [ { field: :status, message: "cannot transition from completed to pending" } ]
          }
        }, status: :unprocessable_entity
      end

      before_action :set_lead, only: %i[index create]
      before_action :set_diagnostic, only: %i[show update]

      def index
        diagnostics = @lead.diagnostics.ordered.page(params[:page]).per(params[:per] || 10)
        render json: {
          data: DiagnosticSerializer.render(diagnostics, view: :extended),
          meta: pagination_meta(diagnostics)
        }
      end

      def show
        render json: { data: DiagnosticSerializer.render(@diagnostic, view: :extended) }
      end

      def create
        diagnostic = @lead.diagnostics.create!(diagnostic_params)
        Diagnostics::ProcessService.new(diagnostic).call if diagnostic.completed?
        render json: { data: DiagnosticSerializer.render(diagnostic) }, status: :created
      end

      def update
        validate_status_transition if params[:diagnostic][:status].present?
        @diagnostic.update!(diagnostic_params)
        Diagnostics::ProcessService.new(@diagnostic).call if @diagnostic.completed?
        render json: { data: DiagnosticSerializer.render(@diagnostic) }
      end

      private

      def set_lead
        @lead = Lead.find(params[:lead_id])
      end

      def set_diagnostic
        @diagnostic = Diagnostic.find(params[:id])
      end

      def diagnostic_params
        params.require(:diagnostic).permit(:status, :fit_score, :critical_pain, raw_responses: {})
      end

      def validate_status_transition
        new_status = params[:diagnostic][:status].to_s
        return unless @diagnostic.completed? && new_status == "pending"

        raise InvalidTransitionError, "Cannot revert a completed diagnostic back to pending"
      end

      def pagination_meta(collection)
        {
          current_page: collection.current_page,
          next_page: collection.next_page,
          prev_page: collection.prev_page,
          total_pages: collection.total_pages,
          total_count: collection.total_count
        }
      end
    end
  end
end
