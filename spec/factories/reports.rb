FactoryBot.define do
  factory :report do
    diagnostic
    report_type { "n8n_diagnostic" }
    overall_score { %w[excellent good moderate poor critical].sample }
    recommendation { %w[growth_partner implementacion diagnostico_premium autoservicio].sample }
    processed { true }
    raw_data { { "lead_nombre" => "Test Lead", "session_id" => "test-#{SecureRandom.hex(4)}" } }
    scoring do
      {
        "overall_score" => 3.5,
        "overall_label" => "moderate",
        "dimensions" => [
          { "variable" => "fit", "score" => 3, "estado" => "funcional", "weight" => 0.25 }
        ],
        "recommendation" => "implementacion"
      }
    end
  end
end