class Api::V1::Chatbot::MessagesController < ApplicationController
  before_action :set_conversation
  before_action :set_message, only: %i[show update destroy]

  # GET /api/v1/chatbot/conversations/:conversation_id/messages
  def index
    messages = @conversation.messages.ordered
    render json: { data: messages.map { |m| Chatbot::MessageSerializer.render_as_hash(m) } }
  end

  # GET /api/v1/chatbot/messages/:id
  def show
    render json: { data: Chatbot::MessageSerializer.render_as_hash(@message, view: :extended) }
  end

  # POST /api/v1/chatbot/conversations/:conversation_id/messages
  def create
    message = @conversation.messages.build!(message_params.merge(role: "user"))
    message.save!
    ProcessMessageJob.perform_later(message.id)
    render json: { data: Chatbot::MessageSerializer.render_as_hash(message, view: :extended) },
           status: :created
  end

  # PATCH /api/v1/chatbot/messages/:id
  def update
    @message.update!(message_params)
    render json: { data: Chatbot::MessageSerializer.render_as_hash(@message) }
  end

  # DELETE /api/v1/chatbot/messages/:id
  def destroy
    @message.destroy!
    head :no_content
  end

  private

  def set_conversation
    @conversation = current_lead.conversations.active.find(params[:conversation_id])
  end

  def set_message
    @message = @conversation.messages.find(params[:id])
  end

  def message_params
    params.require(:message).permit(:content, metadata: {})
  end

  def current_lead
    @current_lead ||= Lead.find(@current_payload[:lead_id])
  end
end