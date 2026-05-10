module Api
  module V1
    class LeadsController < ApplicationController
      rescue_from ActiveRecord::RecordNotUnique, with: :duplicate_email

      before_action :set_company, only: %i[index create]
      before_action :set_lead, only: %i[show update]

      def index
        leads = @company.leads.ordered.page(params[:page]).per(params[:per] || 10)
        render json: {
          data: LeadSerializer.render_as_hash(leads),
          meta: pagination_meta(leads)
        }
      end

      def show
        render json: { data: LeadSerializer.render_as_hash(@lead) }
      end

      def create
        lead = @company.leads.create!(lead_params)
        render json: { data: LeadSerializer.render_as_hash(lead) }, status: :created
      end

      def update
        @lead.update!(lead_params)
        render json: { data: LeadSerializer.render_as_hash(@lead) }
      end

      private

      def set_company
        @company = Company.find(params[:company_id])
      end

      def set_lead
        @lead = Lead.find(params[:id])
      end

      def lead_params
        params.require(:lead).permit(:full_name, :email, :role)
      end

      def duplicate_email(exception)
        render json: {
          error: {
            code: ErrorCodes::CONFLICT,
            message: "A lead with this email already exists",
            status: 409,
            details: [ { field: :email, message: "has already been taken" } ]
          }
        }, status: :conflict
      end

      def pagination_meta(collection)
        {
          current_page: collection.current_page,
          next_page: collection.next_page,
          prev_page: collection.prev_page,
          total_pages: collection.total_pages,
          total_count: collection.total_count
        }
      end
    end
  end
end
