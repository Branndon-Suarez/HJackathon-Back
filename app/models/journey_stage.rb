class JourneyStage < ApplicationRecord
  belongs_to :strategy_plan

  validates :stage_name, presence: true
  validates :order, presence: true,
                    numericality: { only_integer: true },
                    uniqueness: { scope: :strategy_plan_id }
end
