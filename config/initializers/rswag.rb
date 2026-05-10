Rswag::Ui.configure do |config|
  config.swagger_endpoint "/api-docs/v1/swagger.yaml", "API V1 Docs"
end

Rswag::Api.configure do |config|
  config.swagger_root = Rails.root.join("swagger").to_s
  config.swagger_filter = lambda { |swagger, env| swagger }
end
