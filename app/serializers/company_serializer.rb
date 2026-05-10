class CompanySerializer < Blueprinter::Base
  identifier :id

  fields :name, :industry, :stage, :team_size, :created_at

  view :extended do
    association :leads, blueprint: LeadSerializer
  end
end
