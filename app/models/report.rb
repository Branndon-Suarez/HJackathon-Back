class Report < ApplicationRecord
  belongs_to :diagnostic

  validates :report_type, presence: true
  validates :diagnostic_id, uniqueness: true

  enum :overall_score, {
    excellent: "excellent",
    good: "good",
    moderate: "moderate",
    poor: "poor",
    critical: "critical"
  }, _prefix: :score

  scope :ordered, -> { order(created_at: :desc) }
  scope :processed, -> { where(processed: true) }
end