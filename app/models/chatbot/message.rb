module Chatbot
  class Message < ApplicationRecord
    self.table_name = "messages"

    belongs_to :conversation

    validates :role, presence: true, inclusion: { in: %w[user bot] }
    validates :content, presence: true

    scope :ordered, -> { order(created_at: :asc) }
    scope :user_messages, -> { where(role: "user").ordered }
    scope :bot_messages, -> { where(role: "bot").ordered }
  end
end