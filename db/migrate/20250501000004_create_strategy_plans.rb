class CreateStrategyPlans < ActiveRecord::Migration[7.2]
  def change
    create_table :strategy_plans, id: :uuid do |t|
      t.references :diagnostic, null: false, foreign_key: true, type: :uuid
      t.text :executive_summary
      t.string :audio_briefing_url
      t.jsonb :kpis
      t.jsonb :okrs

      t.timestamps
    end
  end
end
