module Api
  module V1
    class PingController < ApplicationController
      skip_before_action :authenticate_request!, only: %i[show]

      def show
        render json: { ok: true, message: "pong", rails_env: Rails.env }
      end
    end
  end
end
