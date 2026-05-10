FactoryBot.define do
  factory :journey_stage do
    strategy_plan
    stage_name { %w[Consciencia Consideración Conversión Retención Referido].sample }
    description { Faker::Lorem.sentence }
    action_items { [ Faker::Lorem.sentence ] }
    order { rand(1..5) }
  end
end
