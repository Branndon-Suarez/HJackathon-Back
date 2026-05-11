FactoryBot.define do
  factory :chatbot_conversation, class: "Chatbot::Conversation" do
    association :lead, factory: :lead
    status { "active" }
    metadata { { source: "chatbot" } }
    message_count { 0 }

    trait :paused do
      status { "paused" }
    end

    trait :completed do
      status { "completed" }
    end
  end

  factory :chatbot_message, class: "Chatbot::Message" do
    association :conversation, factory: :chatbot_conversation
    role { "user" }
    content { "Mensaje de prueba" }
    metadata { {} }

    trait :as_bot do
      role { "bot" }
      metadata { { "interpretation" => "welcome" } }
    end
  end
end