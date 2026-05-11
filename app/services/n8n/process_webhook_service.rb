module N8n
  class ProcessWebhookService
    def self.call(diagnostic, payload)
      new(diagnostic, payload).execute
    end

    def initialize(diagnostic, payload)
      @diagnostic = diagnostic
      @payload = payload.with_indifferent_access # Para acceder por :llave o "llave"
    end

    def execute
      ActiveRecord::Base.transaction do
        update_diagnostic
        update_company_and_lead
        create_strategy_plan
      end
      true
    rescue => e
      Rails.logger.error "❌ Error en N8n::ProcessWebhookService: #{e.message}"
      false
    end

    private

    def update_diagnostic
      @diagnostic.update!(
        status: :completed, # Asegúrate que tu model tenga este estado
        fit_score: @payload[:scoring_score_promedio].to_f,
        commercial_outputs: @payload # Guardamos el JSON gigante aquí por si acaso
      )
    end

    def update_company_and_lead
      lead = @diagnostic.lead
      # Actualizamos con la info fresca de n8n
      lead.update!(full_name: @payload[:lead_nombre]) if @payload[:lead_nombre]
      lead.company.update!(
        name: @payload[:lead_empresa],
        industry: @payload[:lead_sector]
      ) if @payload[:lead_empresa]
    end

    def create_strategy_plan
      # 1. Crear el Plan maestro
      plan = @diagnostic.create_strategy_plan(
        executive_summary: @payload[:dx0_resumen_ejecutivo],
        kpis: {
          ticket_medio: @payload[:metrica_ticket_medio],
          cac: @payload[:metrica_cac],
          ltv: @payload[:metrica_ltv],
          ingreso_potencial: @payload[:metrica_ingreso_potencial]
        },
        okrs: @payload[:scoring_variables_criticas] # n8n envía esto como JSON
      )

      # 2. Mapear el Journey (si n8n lo envía como array en 'plan_customer_journey')
      journey = @payload[:plan_customer_journey]
      if journey.is_a?(Array)
        journey.each_with_index do |stage, index|
          plan.journey_stages.create!(
            stage_name: stage["nombre"] || "Etapa #{index + 1}",
            description: stage["descripcion"],
            action_items: stage["acciones"], # Esto suele ser un array/json
            order: index
          )
        end
      end
    end
  end
end
