class Lead < ApplicationRecord
  belongs_to :company
  has_many :diagnostics, dependent: :destroy

  validates :full_name, presence: true
  validates :email, presence: true, uniqueness: true

  scope :ordered, -> { order(created_at: :desc) }
end
