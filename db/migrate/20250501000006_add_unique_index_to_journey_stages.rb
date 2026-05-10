class AddUniqueIndexToJourneyStages < ActiveRecord::Migration[7.2]
  def change
    add_index :journey_stages, [ :strategy_plan_id, :order ],
              unique: true,
              name: "idx_journey_stages_on_plan_and_order"
  end
end
