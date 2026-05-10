class AddCheckConstraints < ActiveRecord::Migration[7.2]
  def change
    add_check_constraint :companies, "stage IN (0, 1, 2, 3)",
                         name: "chk_companies_stage",
                         validate: false

    add_check_constraint :diagnostics, "status IN (0, 1, 2, 3)",
                         name: "chk_diagnostics_status",
                         validate: false
  end
end
