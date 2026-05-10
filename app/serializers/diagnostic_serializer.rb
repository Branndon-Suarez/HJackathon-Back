class DiagnosticSerializer < Blueprinter::Base
  identifier :id

  fields :status, :raw_responses, :fit_score, :critical_pain,
         :lead_id, :created_at, :commercial_inputs

  field :commercial_outputs do |diagnostic|
    diagnostic.commercial_outputs if diagnostic.completed?
  end

  view :extended do
    association :strategy_plan, blueprint: StrategyPlanSerializer
  end
end
