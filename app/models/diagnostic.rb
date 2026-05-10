class Diagnostic < ApplicationRecord
  belongs_to :lead
  has_one :strategy_plan, dependent: :destroy

  enum :status, { pending: 0, processing: 1, completed: 2, failed: 3 }

  validates :status, presence: true

  scope :ordered, -> { order(created_at: :desc) }

  store_accessor :commercial_inputs, :lead_info, :business_context, :commercial_variables,
                 :objectives_and_constraints, :fit_ribuzz

  store_accessor :commercial_outputs, :general_diagnosis, :variable_scoring,
                 :value_equation_diagnosis, :acquisition_channel_diagnosis,
                 :cac_diagnosis, :top_3_priorities, :improvement_plan,
                 :customer_journey, :internal_commercial_output,
                 :ribuzz_offer_recommendation, :final_decision
end
