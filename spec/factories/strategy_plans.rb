FactoryBot.define do
  factory :strategy_plan do
    diagnostic
    executive_summary { Faker::Lorem.paragraph }
    audio_briefing_url { Faker::Internet.url }
    kpis { [ { name: "Tasa de conversión", target: "15%" } ] }
    okrs { [ { objective: "Crecimiento", key_results: [ "Meta 1", "Meta 2" ] } ] }
  end
end
