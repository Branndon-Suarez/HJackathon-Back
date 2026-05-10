FactoryBot.define do
  factory :lead do
    company
    full_name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    role { %w[CEO Sales_Director CTO CMO Founder].sample }
  end
end
