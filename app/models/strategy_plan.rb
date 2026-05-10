class StrategyPlan < ApplicationRecord
  belongs_to :diagnostic
  has_many :journey_stages, dependent: :destroy
end

##
# - id:uuid(PK)
# - diagnostic_id:uuid(FK -> diagnostics.id)
# - executive_summary:text(Resumen de alto nivel)
# - audio_briefing_url:string(URL del archivo en Supabase Storage de ElevenLabs)
# - kpis:jsonb(Lista de indicadores clave sugeridos)
# - okrs:jsonb(Objetivos y resultados clave a 90 días)
# - created_at:timestamp