class CreateConversations < ActiveRecord::Migration[7.2]
  def change
    create_table :conversations, id: :uuid do |t|
      t.references :lead, null: false, foreign_key: true, type: :uuid
      t.integer :status, default: 0, null: false
      t.jsonb :metadata, default: {}
      t.integer :message_count, default: 0

      t.timestamps
    end

    add_index :conversations, :status
    add_index :conversations, :created_at
  end
end