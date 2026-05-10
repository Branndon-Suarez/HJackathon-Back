class CreateCompanies < ActiveRecord::Migration[7.2]
  def change
    create_table :companies, id: :uuid do |t|
      t.string :name, null: false
      t.string :industry
      t.integer :stage, default: 0
      t.integer :team_size

      t.timestamps
    end
  end
end
