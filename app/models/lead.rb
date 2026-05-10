class Lead < ApplicationRecord
  belongs_to :company
  has_many :diagnostics, dependent: :destroy

  validates :full_name, presence: true
  validates :email, presence: true, uniqueness: true
end

##
# - id:uuid(PK)
# - company_id:uuid(FK -> companies.id)
# - full_name:string
# - email:string(Unique)
# - role:string(CEO, Sales Director, etc.)
# - created_at:timestamp