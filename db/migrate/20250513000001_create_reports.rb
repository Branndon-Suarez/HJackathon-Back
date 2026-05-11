class CreateReports < ActiveRecord::Migration[7.2]
  def change
    create_table :reports, id: :uuid do |t|
      t.references :diagnostic, null: false, foreign_key: true, type: :uuid
      t.string :report_type, null: false
      t.string :overall_score
      t.text :recommendation
      t.boolean :processed, default: false, null: false
      t.text :error_message
      t.jsonb :raw_data, default: {}
      t.jsonb :scoring, default: {}
      t.timestamps
    end

    add_index :reports, :report_type
    add_index :reports, :processed
    add_index :reports, :created_at
  end
end
