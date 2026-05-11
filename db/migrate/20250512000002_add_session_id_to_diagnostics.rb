class AddSessionIdToDiagnostics < ActiveRecord::Migration[7.2]
  def change
    add_column :diagnostics, :session_id, :string
    add_index :diagnostics, :session_id, unique: true, where: "session_id IS NOT NULL"
  end
end