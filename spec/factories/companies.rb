FactoryBot.define do
  factory :company do
    name { Faker::Company.name }
    industry { Faker::IndustrySegments.sector }
    stage { Company.stages.keys.sample }
    team_size { rand(5..500) }
  end
end
