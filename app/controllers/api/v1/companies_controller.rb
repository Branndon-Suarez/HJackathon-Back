module Api
  module V1
    class CompaniesController < ApplicationController
      before_action :set_company, only: %i[show update]

      def index
        companies = Company.ordered.page(params[:page]).per(params[:per] || 10)
        render json: {
          data: CompanySerializer.render_as_hash(companies, view: :extended),
          meta: pagination_meta(companies)
        }
      end

      def show
        render json: { data: CompanySerializer.render_as_hash(@company, view: :extended) }
      end

      def create
        company = Company.create!(company_params)
        render json: { data: CompanySerializer.render_as_hash(company) }, status: :created
      end

      def update
        @company.update!(company_params)
        render json: { data: CompanySerializer.render_as_hash(@company) }
      end

      private

      def set_company
        @company = Company.find(params[:id])
      end

      def company_params
        params.require(:company).permit(:name, :industry, :stage, :team_size)
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
