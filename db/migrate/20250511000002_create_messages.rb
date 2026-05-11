class CreateMessages < ActiveRecord::Migration[7.2]
  def change
    create_table :messages, id: :uuid do |t|
      t.references :conversation, null: false, foreign_key: true, type: :uuid
      t.string :role, null: false  # "user" o "bot"
      t.text :content, null: false
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :messages, [:conversation_id, :created_at]
    add_index :messages, :role
  end
end