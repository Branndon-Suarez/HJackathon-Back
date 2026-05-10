class Company < ApplicationRecord
  has_many :leads, dependent: :destroy

  enum :stage, { seed: 0, early_growth: 1, scaling: 2, mature: 3 }

  validates :name, presence: true

  scope :ordered, -> { order(created_at: :desc) }
end
