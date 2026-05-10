class JourneyStageSerializer < Blueprinter::Base
  identifier :id

  fields :stage_name, :description, :action_items, :order, :strategy_plan_id, :created_at
end
