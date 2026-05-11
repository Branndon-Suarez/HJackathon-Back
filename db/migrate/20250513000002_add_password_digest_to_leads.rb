class AddPasswordDigestToLeads < ActiveRecord::Migration[7.2]
  def change
    add_column :leads, :password_digest, :string
  end
end
