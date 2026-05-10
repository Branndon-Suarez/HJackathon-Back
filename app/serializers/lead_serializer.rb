class LeadSerializer < Blueprinter::Base
  identifier :id

  fields :full_name, :email, :role, :company_id, :created_at
end
