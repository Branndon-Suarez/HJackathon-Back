module Diagnostics
  class CalculateFitScoreService
    def initialize(diagnostic)
      @diagnostic = diagnostic
      @responses = diagnostic.raw_responses || {}
      @inputs = diagnostic.commercial_inputs || {}
    end

    def call
      score = compute_score
      pain = detect_critical_pain

      @diagnostic.update!(
        fit_score: score,
        critical_pain: pain
      )

      { fit_score: score, critical_pain: pain }
    end

    private

    def compute_score
      # Try new structure first
      variables = @responses["variables"] || @responses[:variables] || {}
      lead = @responses["lead"] || @responses[:lead] || {}

      answered = 0
      total = 0

      # Count total fields with values
      collect_values(variables).each do |val|
        total += 1
        answered += 1 if val.present?
      end

      collect_values(lead).each do |val|
        total += 1
        answered += 1 if val.present?
      end

      # Fallback to old structure
      if total == 0
        positive = @responses.values.count { |v| v.to_s.downcase == "si" || v.to_s.downcase == "yes" }
        total = @responses.values.size
        return 0 if total.zero?
        return ((positive.to_f / total) * 100).round
      end

      ((answered.to_f / total) * 100).round
    end

    def detect_critical_pain
      # Look for low-scoring or missing critical fields
      variables = @responses["variables"] || @responses[:variables] || {}
      problemas = variables["problema"] || variables[:problema] || {}

      if problemas["problema_que_resuelve"].blank?
        return "No se ha definido un problema crítico"
      end

      oferta = variables["oferta"] || variables[:oferta] || {}
      if oferta["promesa_principal"].blank?
        return "Falta definir la promesa de valor"
      end

      monetizacion = variables["monetizacion"] || variables[:monetizacion] || {}
      if monetizacion["ticket_medio"].blank?
        return "No se ha definido el modelo de monetización"
      end

      nil
    end

    def collect_values(hash)
      return [] if hash.blank?
      hash.values.select { |v| v.is_a?(String) || v.is_a?(Numeric) }
    end
  end
end