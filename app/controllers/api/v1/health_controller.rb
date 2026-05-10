module Api
  module V1
    class HealthController < ApplicationController
      skip_before_action :authenticate_request!, only: %i[show]

      def show
        ActiveRecord::Base.connection.execute("SELECT 1")

        render json: {
          status: "ok",
          database: "connected",
          rails_env: Rails.env,
          ruby_version: RUBY_VERSION,
          time: Time.current.iso8601
        }
      rescue ActiveRecord::StatementInvalid => e
        render json: {
          status: "error",
          database: "disconnected",
          error: e.message
        }, status: :service_unavailable
      end
    end
  end
end
