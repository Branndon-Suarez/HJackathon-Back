# Job that processes a user message asynchronously and generates a bot response
class ProcessMessageJob < ApplicationJob
  queue_as :default

  def perform(message_id)
    message = Chatbot::Message.find(message_id)
    conversation = message.conversation

    result = Chatbot::Orchestrator.new(conversation).call

    conversation.messages.create!(
      role: "bot",
      content: serialize_response(result),
      metadata: {
        interpretation: result[:type].to_s,
        suggested_actions: result[:actions]&.map { |a| a[:trigger] || a[:label] } || []
      }
    )
  end

  private

  def serialize_response(result)
    content = result[:content].to_s
    if result[:actions].present?
      actions_text = result[:actions].map { |a| "[#{a[:label] || a[:trigger]}]" }.join(" ")
      "#{content}\n\n#{actions_text}"
    else
      content
    end
  end
end