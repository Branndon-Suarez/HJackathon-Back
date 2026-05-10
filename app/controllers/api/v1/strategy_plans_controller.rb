module Api
  module V1
    class StrategyPlansController < ApplicationController
      rescue_from DuplicatePlanError do |e|
        render json: {
          error: {
            code: ErrorCodes::CONFLICT,
            message: e.message,
            status: 409,
            details: [ { field: :diagnostic_id, message: "already has a strategy plan" } ]
          }
        }, status: :conflict
      end

      before_action :set_diagnostic, only: %i[show create]
      before_action :set_strategy_plan, only: %i[update]

      def show
        plan = @diagnostic.strategy_plan || raise(ActiveRecord::RecordNotFound, "Strategy plan not found")
        render json: { data: StrategyPlanSerializer.render(plan, view: :extended) }
      end

      def create
        raise DuplicatePlanError, "This diagnostic already has a strategy plan" if @diagnostic.strategy_plan.present?

        plan = @diagnostic.create_strategy_plan!(strategy_plan_params)
        render json: { data: StrategyPlanSerializer.render(plan) }, status: :created
      end

      def update
        @strategy_plan.update!(strategy_plan_params)
        render json: { data: StrategyPlanSerializer.render(@strategy_plan) }
      end

      private

      def set_diagnostic
        @diagnostic = Diagnostic.find(params[:diagnostic_id])
      end

      def set_strategy_plan
        @strategy_plan = StrategyPlan.find(params[:id])
      end

      def strategy_plan_params
        params.require(:strategy_plan).permit(:executive_summary, :audio_briefing_url, kpis: {}, okrs: {})
      end
    end
  end
end
