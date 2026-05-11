class Api::V1::Chatbot::ConversationsController < ApplicationController
  before_action :set_conversation, only: %i[show update destroy]

  # GET /api/v1/chatbot/conversations
  def index
    conversations = current_lead.conversations.ordered
    render json: {
      data: conversations.map { |c| Chatbot::ConversationSerializer.render_as_hash(c) },
      meta: { total: conversations.count }
    }
  end

  # POST /api/v1/chatbot/conversations
  def create
    conversation = current_lead.conversations.build!(conversation_params)
    conversation.status = :active
    conversation.save!

    conversation.messages.create!(role: "bot",
      content: "Hola. Soy tu asistente de diagnostico comercial. En que puedo ayudarte?")

    render json: { data: Chatbot::ConversationSerializer.render_as_hash(conversation, view: :extended) },
           status: :created
  end

  # GET /api/v1/chatbot/conversations/:id
  def show
    render json: { data: Chatbot::ConversationSerializer.render_as_hash(@conversation, view: :extended) }
  end

  # PATCH /api/v1/chatbot/conversations/:id
  def update
    @conversation.update!(conversation_params)
    render json: { data: Chatbot::ConversationSerializer.render_as_hash(@conversation) }
  end

  # DELETE /api/v1/chatbot/conversations/:id
  def destroy
    @conversation.destroy!
    head :no_content
  end

  private

  def set_conversation
    @conversation = current_lead.conversations.find(params[:id])
  end

  def conversation_params
    params.require(:conversation).permit(:status, metadata: {})
  end

  def current_lead
    @current_lead ||= Lead.find(@current_payload[:lead_id])
  end
end