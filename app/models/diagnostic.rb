class Diagnostic < ApplicationRecord
  belongs_to :lead
  has_one :strategy_plan, dependent: :destroy

  enum :status, { pending: 0, processing: 1, completed: 2, failed: 3 }

  validates :status, presence: true

  scope :ordered, -> { order(created_at: :desc) }
end
