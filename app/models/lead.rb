class Lead < ApplicationRecord
  belongs_to :company
  has_many :diagnostics, dependent: :destroy
  has_many :reports, through: :diagnostics

  validates :full_name, presence: true
  validates :email, presence: true, uniqueness: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  scope :ordered, -> { order(created_at: :desc) }
end