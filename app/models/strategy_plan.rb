class StrategyPlan < ApplicationRecord
  belongs_to :diagnostic
  has_many :journey_stages, dependent: :destroy
end
