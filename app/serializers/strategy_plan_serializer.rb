class StrategyPlanSerializer < Blueprinter::Base
  identifier :id

  fields :executive_summary, :audio_briefing_url, :kpis, :okrs, :diagnostic_id, :created_at

  view :extended do
    association :journey_stages, blueprint: JourneyStageSerializer
  end
end
