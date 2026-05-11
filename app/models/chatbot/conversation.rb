module Chatbot
  class Conversation < ApplicationRecord
    self.table_name = "conversations"

    belongs_to :lead
    has_many :messages, dependent: :destroy

    enum :status, { active: 0, paused: 1, completed: 2, archived: 3 }

    validates :status, presence: true
    validates :lead_id, uniqueness: { scope: :status, conditions: -> { where(status: :active) },
                                      message: "already has an active conversation" }
  end
end