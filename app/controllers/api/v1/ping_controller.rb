module Api
  module V1
    class PingController < ApplicationController
      def show
        render json: { ok: true, message: "pong", rails_env: Rails.env }
      end
    end
  end
end
