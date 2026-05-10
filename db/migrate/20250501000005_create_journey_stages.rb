class CreateJourneyStages < ActiveRecord::Migration[7.2]
  def change
    create_table :journey_stages, id: :uuid do |t|
      t.references :strategy_plan, null: false, foreign_key: true, type: :uuid
      t.string :stage_name, null: false
      t.text :description
      t.jsonb :action_items
      t.integer :order, null: false, default: 0

      t.timestamps
    end
  end
end
