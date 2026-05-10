module RiBuzz
  class PriorityEngine
    CRITERIA_WEIGHTS = {
      blocks_sales: 5,
      affects_multiple: 4,
      low_investment: 3,
      leads_to_sale: 4,
      fixes_root_cause: 5,
      cash_flow_impact: 4
    }.freeze

    def initialize(scoring_result, commercial_inputs)
      @scoring = scoring_result
      @inputs = commercial_inputs.with_indifferent_access
      @scores = @scoring[:scores]
    end

    def call
      priorities = @scores.map { |s| evaluate_variable(s) }
                          .sort_by { |p| -p[:peso_total] }
                          .first(3)

      priorities.each_with_index.map do |p, i|
        p.merge(orden: i + 1, razon: build_reason(p))
      end
    end

    private

    def evaluate_variable(score_item)
      variable_key = find_variable_key(score_item[:variable])
      score = score_item[:score]

      raw = 0
      raw += CRITERIA_WEIGHTS[:blocks_sales] if score <= 2
      raw += CRITERIA_WEIGHTS[:affects_multiple] if affects_multiple?(variable_key)
      raw += CRITERIA_WEIGHTS[:low_investment] if low_investment_possible?(variable_key)
      raw += CRITERIA_WEIGHTS[:leads_to_sale] if leads_to_sale?(variable_key)
      raw += CRITERIA_WEIGHTS[:fixes_root_cause] if is_root_cause?(score)
      raw += CRITERIA_WEIGHTS[:cash_flow_impact] if cash_flow_impact?(variable_key)

      {
        variable: score_item[:variable],
        score_actual: score,
        peso_total: raw,
        accion_inicial: build_initial_action(score_item[:variable]),
        metrica: build_metric(score_item[:variable]),
        impacto_esperado: build_impact(score_item[:variable])
      }
    end

    def find_variable_key(label)
      RiBuzz::ScoringService::SCORING_RULES.each do |key, rule|
        return key if rule[:label] == label
      end
      nil
    end

    def affects_multiple?(key)
      %i[offer value_equation conversion follow_up].include?(key)
    end

    def low_investment_possible?(key)
      %i[offer follow_up conversion icp].include?(key)
    end

    def leads_to_sale?(key)
      %i[offer conversion follow_up scaling].include?(key)
    end

    def is_root_cause?(score)
      score <= 2
    end

    def cash_flow_impact?(key)
      %i[ticket recurrence conversion cac].include?(key)
    end

    def build_reason(priority)
      reasons = []
      reasons << "Bloquea ventas directamente" if priority[:score_actual] <= 2
      reasons << "Afecta múltiples variables del sistema" if priority[:peso_total] >= 10
      reasons << "Alto impacto en flujo de caja" if priority[:peso_total] >= 12
      reasons << "Mejora sin alta inversión" if priority[:peso_total] >= 8
      reasons.first(2).join(". ")
    end

    def build_initial_action(variable)
      actions = {
        "Oferta" => "Redefinir propuesta de valor y promesa principal",
        "Conversión" => "Diseñar proceso de conversión con pasos claros",
        "Seguimiento" => "Implementar CRM y rutina de seguimiento",
        "CAC" => "Medir y desglosar costos de adquisición",
        "Canal principal de adquisición" => "Auditar canal principal y diversificar",
        "Ecuación de valor" => "Fortalecer palanca más débil de la ecuación",
        "ICP" => "Definir perfil de cliente ideal con datos reales",
        "Ticket medio" => "Evaluar estructura de precios y empaquetado",
        "Recurrencia" => "Diseñar modelo de recurrencia o recompra",
        "Solución" => "Clarificar mecanismo de solución y diferenciador",
        "Problema" => "Precisar el dolor y su urgencia",
        "Cliente actual" => "Segmentar clientes por valor y fit",
        "Escalamiento" => "Documentar procesos y delegar",
        "Etapa del negocio" => "Validar modelo antes de escalar",
        "Capacidad de ejecución" => "Liberar capacidad con herramientas y delegación"
      }
      actions[variable] || "Diagnosticar y priorizar acciones para #{variable.downcase}"
    end

    def build_metric(variable)
      metrics = {
        "Oferta" => "Tasa de conversión",
        "Conversión" => "% de leads que compran",
        "Seguimiento" => "Tasa de respuesta en seguimiento",
        "CAC" => "Costo de adquisición mensual",
        "Canal principal de adquisición" => "Clientes nuevos por canal",
        "Ecuación de valor" => "Percepción de valor en encuesta",
        "ICP" => "% de clientes que cumplen ICP",
        "Ticket medio" => "Ticket promedio mensual",
        "Recurrencia" => "Tasa de recompra mensual",
        "Solución" => "NPS o satisfacción",
        "Problema" => "Urgencia declarada por cliente",
        "Cliente actual" => "Churn rate",
        "Escalamiento" => "Ventas sin intervención del fundador",
        "Etapa del negocio" => "Ingresos recurrentes",
        "Capacidad de ejecución" => "Tareas completadas vs planificadas"
      }
      metrics[variable] || "Métrica por definir"
    end

    def build_impact(variable)
      impacts = {
        "Oferta" => "Mayor conversión y ticket medio",
        "Conversión" => "Más clientes con mismo tráfico",
        "Seguimiento" => "Recuperación de leads perdidos",
        "CAC" => "Rentabilidad en adquisición",
        "Canal principal de adquisición" => "Menor dependencia y más leads",
        "Ecuación de valor" => "Oferta más convincente",
        "ICP" => "Mejor calidad de leads",
        "Ticket medio" => "Mayor ingreso por cliente",
        "Recurrencia" => "Ingresos predecibles",
        "Solución" => "Menos objeciones de venta",
        "Problema" => "Mensaje de venta más potente",
        "Cliente actual" => "Mayor retención y LTV",
        "Escalamiento" => "Ventas sin depender del fundador",
        "Etapa del negocio" => "Claridad estratégica",
        "Capacidad de ejecución" => "Implementación más rápida"
      }
      impacts[variable] || "Mejora en variable #{variable.downcase}"
    end
  end
end
