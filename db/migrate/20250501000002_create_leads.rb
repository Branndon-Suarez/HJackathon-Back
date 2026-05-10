class CreateLeads < ActiveRecord::Migration[7.2]
  def change
    create_table :leads, id: :uuid do |t|
      t.references :company, null: false, foreign_key: true, type: :uuid
      t.string :full_name, null: false
      t.string :email, null: false
      t.string :role

      t.timestamps
    end

    add_index :leads, :email, unique: true
  end
end
