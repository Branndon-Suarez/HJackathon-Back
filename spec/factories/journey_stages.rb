FactoryBot.define do
  sequence(:journey_stage_order) { |n| n }

  factory :journey_stage do
    strategy_plan
    stage_name { %w[Consciencia Consideración Conversión Retención Referido].sample }
    description { Faker::Lorem.sentence }
    action_items { [ Faker::Lorem.sentence ] }
    order { generate(:journey_stage_order) }
  end
end
