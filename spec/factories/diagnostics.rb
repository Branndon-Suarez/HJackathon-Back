FactoryBot.define do
  factory :diagnostic do
    lead
    status { :pending }
    raw_responses { { q1: "Si", q2: "No", q3: "Tal vez" } }
    fit_score { nil }
    critical_pain { nil }
  end
end
