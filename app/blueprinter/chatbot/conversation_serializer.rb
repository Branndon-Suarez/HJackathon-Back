Blueprinter::Serializer.for(Chatbot::Conversation) do
  field :id, name: :id
  field :status
  field :message_count
  field :created_at
  field :updated_at

  association :messages,
    blueprint: Chatbot::MessageSerializer,
    name: :messages,
    if: ->(_, _opts) { true }

  view :extended do
    association :lead,
      blueprint: Api::V1::LeadSerializer,
      name: :lead,
      if: ->(_, _opts) { true }

    field :metadata
  end
end