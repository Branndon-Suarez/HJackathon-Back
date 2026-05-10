class AddCommercialFieldsToDiagnostics < ActiveRecord::Migration[7.2]
  def change
    add_column :diagnostics, :commercial_inputs, :jsonb, default: {}
    add_column :diagnostics, :commercial_outputs, :jsonb, default: {}
    add_index :diagnostics, :commercial_inputs, using: :gin
    add_index :diagnostics, :commercial_outputs, using: :gin
  end
end
