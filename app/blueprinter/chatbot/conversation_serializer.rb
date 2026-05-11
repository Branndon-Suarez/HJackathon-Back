require 'blueprinter'

module Chatbot
  class ConversationSerializer < Blueprinter::Base
    identifier :id

    field :status
    field :message_count
    field :created_at
    field :updated_at

    association :messages,
                blueprint: Chatbot::MessageSerializer

    view :extended do
      association :lead,
                  blueprint: Api::V1::LeadSerializer
      field :metadata
    end
  end
end
