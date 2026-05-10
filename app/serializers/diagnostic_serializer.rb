class DiagnosticSerializer < Blueprinter::Base
  identifier :id

  fields :status, :raw_responses, :fit_score, :critical_pain, :lead_id, :created_at

  view :extended do
    association :strategy_plan, blueprint: StrategyPlanSerializer
  end
end
