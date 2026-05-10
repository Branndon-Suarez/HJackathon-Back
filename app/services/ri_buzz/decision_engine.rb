module RiBuzz
  class DecisionEngine
    def initialize(commercial_inputs, scoring_result, general_diagnosis)
      @inputs = commercial_inputs.with_indifferent_access
      @scoring = scoring_result
      @diagnosis = general_diagnosis
    end

    def call
      fit = calculate_fit
      {
        fit: fit,
        nivel_confianza_fit: confidence_level(fit),
        recommended_service: recommended_service,
        reason: build_reason,
        next_action: build_next_action,
        probability: conversion_probability
      }
    end

    private

    def calculate_fit
      score = 0
      score += 1 if pain_addressable?
      score += 1 if willingness_to_pay?
      score += 1 if coachable?
      score += 1 if urgency?
      score += 1 if marketing_tech_fit?
      score += 1 if execution_capacity?
      score += 1 if already_selling?

      case score
      when 6..7 then { level: "estrategico", score: score }
      when 4..5 then { level: "alto", score: score }
      when 2..3 then { level: "medio", score: score }
      when 1 then { level: "bajo", score: score }
      else { level: "no_fit", score: 0 }
      end
    end

    def pain_addressable?
      @scoring[:weighted_average] <= 3.0
    end

    def willingness_to_pay?
      input_fit = @inputs.dig(:fit_ribuzz, :willingness_to_pay).to_s.downcase
      return true if input_fit == "alto"
      return false if input_fit == "bajo"

      ticket = @inputs.dig(:commercial_variables, :monetizacion, :ticket_medio).to_s.gsub(/[^0-9.]/, "").to_f
      ticket >= 50
    end

    def coachable?
      input_fit = @inputs.dig(:fit_ribuzz, :coachability).to_s.downcase
      return true if input_fit == "alto"
      return false if input_fit == "bajo"

      execution = @inputs.dig(:commercial_variables, :ejecucion, :capacidad_de_ejecucion).to_s.downcase
      execution != "baja"
    end

    def urgency?
      input_fit = @inputs.dig(:fit_ribuzz, :urgencia).to_s.downcase
      return true if input_fit == "alta"
      return false if input_fit == "baja"

      problem = @inputs.dig(:commercial_variables, :problema, :urgencia_del_problema).to_s.downcase
      problem == "alta"
    end

    def marketing_tech_fit?
      input_fit = @inputs.dig(:fit_ribuzz, :fit_marketing_tecnologia).to_s.downcase
      return true if input_fit == "alto"
      return false if input_fit == "bajo"

      # infer from existing tools
      tools = @inputs.dig(:commercial_variables, :ejecucion, :herramientas_actuales)
      tools.present? && tools.any?
    end

    def execution_capacity?
      input_fit = @inputs.dig(:fit_ribuzz, :capacidad_de_ejecucion_cliente).to_s.downcase
      return true if input_fit == "alta"
      return false if input_fit == "baja"

      @scoring[:scores].any? { |s| s[:variable] == "Capacidad de ejecución" && s[:score] >= 3 }
    end

    def already_selling?
      stage = @inputs.dig(:business_context, :etapa_actual).to_s.downcase
      %w[operacion crecimiento transformacion].include?(stage)
    end

    def recommended_service
      fit = calculate_fit
      level = fit[:level]

      return "no_fit" if level == "no_fit" || level == "bajo"

      if level == "estrategico" || urgent_and_capable?
        "growth_partner"
      elsif structured_enough?
        "implementacion"
      elsif needs_design?
        "diseno_sistema_comercial"
      elsif needs_clarity?
        "diagnostico_premium"
      else
        "autoservicio"
      end
    end

    def urgent_and_capable?
      urgency? && execution_capacity? && @scoring[:weighted_average] >= 2.5
    end

    def structured_enough?
      @scoring[:weighted_average] >= 3.0 && already_selling?
    end

    def needs_design?
      @scoring[:weighted_average] >= 2.0 && @scoring[:weighted_average] < 3.0
    end

    def needs_clarity?
      @scoring[:weighted_average] < 2.0
    end

    def build_reason
      fit = calculate_fit
      top_pain = find_top_pain

      reasons = []
      reasons << "La empresa #{already_selling? ? 'ya vende' : 'está en etapa temprana'}"
      reasons << "dolor identificado en: #{top_pain}" if top_pain
      reasons << "fit #{fit[:level]} (#{fit[:score]}/7 variables)"
      reasons.join(". ")
    end

    def find_top_pain
      worst = @scoring[:scores].min_by { |s| s[:score] }
      worst[:variable] if worst && worst[:score] <= 2
    end

    def build_next_action
      service = recommended_service

      case service
      when "no_fit"
        "Enviar recursos gratuitos y mantener en nurturing"
      when "autoservicio"
        "Entregar diagnóstico completo y guía de acción autogestionada"
      when "diagnostico_premium"
        "Agendar llamada para diagnóstico profundo"
      when "diseno_sistema_comercial"
        "Presentar propuesta de diseño de sistema comercial"
      when "implementacion"
        "Presentar plan de implementación con activos concretos"
      when "growth_partner"
        "Agendar reunión ejecutiva para evaluar partnership"
      else
        "Contactar para definir siguiente paso"
      end
    end

    def confidence_level(fit)
      data_points = 0
      total = 7

      data_points += 1 if @inputs.dig(:commercial_variables, :problema, :problema_que_resuelve).present?
      data_points += 1 if @inputs.dig(:commercial_variables, :monetizacion, :ticket_medio).present?
      data_points += 1 if @inputs.dig(:commercial_variables, :monetizacion, :ventas_mensuales_aproximadas).present?
      data_points += 1 if @inputs.dig(:commercial_variables, :adquisicion, :canal_principal_adquisicion, :canal).present?
      data_points += 1 if @inputs.dig(:commercial_variables, :conversion, :conversion_aproximada).present?
      data_points += 1 if @inputs.dig(:business_context, :etapa_actual).present?
      data_points += 1 if @inputs.dig(:business_context, :descripcion_empresa).present?

      ratio = data_points.to_f / total
      case ratio
      when 0.8..1 then "alto"
      when 0.4...0.8 then "medio"
      else "bajo"
      end
    end

    def conversion_probability
      fit = calculate_fit
      case fit[:level]
      when "estrategico" then "alta"
      when "alto" then "alta"
      when "medio" then "media"
      when "bajo" then "baja"
      else "baja"
      end
    end
  end
end
