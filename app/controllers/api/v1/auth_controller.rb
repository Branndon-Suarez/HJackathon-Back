module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authenticate_request!, only: %i[login]

      def login
        lead = Lead.find_by!(email: params[:email])
        token = JsonWebToken.encode(
          lead_id: lead.id,
          company_id: lead.company_id
        )

        render json: {
          token: token,
          lead: LeadSerializer.render(lead)
        }
      end
    end
  end
end
