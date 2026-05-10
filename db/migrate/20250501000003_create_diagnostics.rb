class CreateDiagnostics < ActiveRecord::Migration[7.2]
  def change
    create_table :diagnostics, id: :uuid do |t|
      t.references :lead, null: false, foreign_key: true, type: :uuid
      t.integer :status, default: 0
      t.jsonb :raw_responses
      t.integer :fit_score
      t.string :critical_pain

      t.timestamps
    end
  end
end
