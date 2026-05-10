class JourneyStage < ApplicationRecord
  belongs_to :strategy_plan

  validates :stage_name, presence: true
  validates :order, presence: true, numericality: { only_integer: true }
end

##
# - id:uuid(PK)
# - strategy_plan_id:uuid(FK -> strategy_plans.id)
# - stage_name:string(Consciencia, Consideración, Conversión, Retención, Referido)
# - description:text
# - action_items:jsonb(Lista de tareas específicas por etapa)
# - order:integer(Para asegurar la visualización 1, 2, 3...)