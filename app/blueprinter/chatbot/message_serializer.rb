require 'blueprinter'

module Chatbot
  class MessageSerializer < Blueprinter::Base
    identifier :id

    field :role
    field :content
    field :metadata
    field :created_at

    view :extended do
      field :interpretation_type do |message, _|
        message.metadata["interpretation"]
      end
    end
  end
end
