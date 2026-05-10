module Api
  module V1
    class JourneyStagesController < ApplicationController
      rescue_from ActiveRecord::RecordNotDestroyed, with: :delete_failed

      before_action :set_strategy_plan, only: %i[index create]
      before_action :set_journey_stage, only: %i[update destroy]

      def index
        stages = @strategy_plan.journey_stages.order(:order)
        render json: { data: JourneyStageSerializer.render_as_hash(stages) }
      end

      def create
        stage = @strategy_plan.journey_stages.create!(journey_stage_params)
        render json: { data: JourneyStageSerializer.render_as_hash(stage) }, status: :created
      end

      def update
        @journey_stage.update!(journey_stage_params)
        render json: { data: JourneyStageSerializer.render_as_hash(@journey_stage) }
      end

      def destroy
        @journey_stage.destroy!
        head :no_content
      end

      private

      def set_strategy_plan
        @strategy_plan = StrategyPlan.find(params[:strategy_plan_id])
      end

      def set_journey_stage
        @journey_stage = JourneyStage.find(params[:id])
      end

      def journey_stage_params
        params.require(:journey_stage).permit(:stage_name, :description, :order, action_items: {})
      end

      def delete_failed(exception)
        render json: {
          error: {
            code: ErrorCodes::CONFLICT,
            message: "Cannot delete this stage: #{exception.record.errors.full_messages.join(", ")}",
            status: 409,
            details: nil
          }
        }, status: :conflict
      end
    end
  end
end
