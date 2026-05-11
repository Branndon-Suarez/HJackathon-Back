module Chatbot
  # Interprets raw user messages: extracts intent, entities, sentiment
  # and maps to appropriate RiBuzz service path
  class Interpreter
    INTENT_KEYWORDS = {
      scoring: %w[diagnóstico evaluar score puntuación cuán bueno evaluación],
      journey: %w[viaje recorrido etapas funnel customer journey mapa],
      cac: %w[cac costo adquisición cliente costo lead ltv unit economics],
      pricing: %w[precio tarifa cotización presupuesto cuánto cuesta precio],
      fix: %w[mejorar arreglar optimizar problema debilidad],
      onboarding: %w[empezar comenzar onboarding configurar registro],
      cancel: %w[cancelar parar salir detener],
      help: %w[ayuda ayuda qué puedes hacer qué haces qué hace]
    }.freeze

    ENTITY_PATTERNS = {
      industry: /\b(software|saas|e.?commerce|retail|consultoría|agencia|restaurante|servicio|manufactura|tecnología|healthcare|educación|finanzas)\b/i,
      team_size: /\b(\d+)\s*(personas?|empleados?|gente)\b/i,
      ticket_range: /\b(\$?[\d,.]+)\s*-\s*(\$?[\d,.]+)\b|\b(\$?[\d,.]+)\s*(mensual|mensuales|mes)\b/i
    }.freeze

    class Result < Struct.new(:intent, :confidence, :entities, :raw_text, :needs_clarification)
      def to_h
        { intent: intent, confidence: confidence, entities: entities,
          raw_text: raw_text, needs_clarification: needs_clarification }
      end
    end

    attr_reader :text, :language

    def initialize(text, language: "es")
      @text = text.to_s.strip
      @language = language
    end

    def call
      return Result.new(:empty, 0.0, {}, @text, true) if @text.empty?

      intent = detect_intent
      entities = extract_entities
      confidence = calculate_confidence(intent, entities)
      needs_clarification = confidence < 0.5 || intent == :unknown

      Result.new(intent, confidence, entities, @text, needs_clarification)
    end

    private

    def detect_intent
      scores = INTENT_KEYWORDS.transform_values do |keywords|
        keywords.count { |kw| @text.include?(kw) }
      end

      best = scores.max_by { |_, v| v }
      best && best.last.positive? ? best.first : :unknown
    end

    def extract_entities
      result = {}

      ENTITY_PATTERNS.each do |key, pattern|
        match = @text.match(pattern)
        result[key] = match ? normalize_entity(key, match) : nil
      end

      result.compact
    end

    def normalize_entity(key, match)
      case key
      when :team_size
        { value: match[1].to_i, unit: "people" }
      when :ticket_range
        if match[1] && match[2]
          { min: match[1].gsub(/[$,]/, "").to_f, max: match[2].gsub(/[$,]/, "").to_f }
        elsif match[3]
          { min: match[3].gsub(/[$,]/, "").to_f, unit: match[4] || "month" }
        end
      when :industry
        { value: match[1].downcase, category: classify_industry(match[1]) }
      else
        match.to_s
      end
    end

    def classify_industry(raw)
      tech = %w[software saas tecnología]
      commerce = %w[e.?commerce retail restaurante]
      services = %w[consultoría agencia servicio]

      return :tech if tech.any? { |t| raw.downcase.include?(t) }
      return :commerce if commerce.any? { |t| raw.downcase.include?(t) }
      return :services if services.any? { |t| raw.downcase.include?(t) }

      :other
    end

    def calculate_confidence(intent, entities)
      base = intent == :unknown ? 0.1 : 0.5
      base += entities.size * 0.1
      base += @text.length > 50 ? 0.1 : 0.0
      [base, 1.0].min.round(2)
    end
  end
end