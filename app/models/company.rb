class Company < ApplicationRecord
  has_many :leads, dependent: :destroy

  enum :stage, { seed: 0, early_growth: 1, scaling: 2, mature: 3 }

  validates :name, presence: true
end
##
# - id:uuid(PK, Default:gen_random_uuid())
# - name:string(Nombre de la empresa)
# - industry:string(Sector)
# - stage:enum(seed, early_growth, scaling, mature)
# - team_size:integer
# - created_at:timestamp