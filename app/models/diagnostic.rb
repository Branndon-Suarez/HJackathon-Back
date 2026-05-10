class Diagnostic < ApplicationRecord
  belongs_to :lead
  has_one :strategy_plan, dependent: :destroy

  enum :status, { pending: 0, processing: 1, completed: 2, failed: 3 }

  validates :status, presence: true
end
##
#- id:uuid(PK)
# - lead_id:uuid(FK -> leads.id)
# - status:enum(pending, processing, completed, failed)
# - raw_responses:jsonb(Almacena las 10 respuestas del formulario para trazabilidad)
# - fit_score:integer(Calculado por la lógica de negocio o IA)
# - critical_pain:string(El punto más débil detectado)
# - created_at:timestamp