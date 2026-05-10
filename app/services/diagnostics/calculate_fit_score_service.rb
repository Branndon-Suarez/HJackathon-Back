module Diagnostics
  class CalculateFitScoreService
    def initialize(diagnostic)
      @diagnostic = diagnostic
      @responses = diagnostic.raw_responses || {}
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
      return 0 if @responses.blank?

      positive = @responses.values.count { |v| v.to_s.downcase == "si" || v.to_s.downcase == "yes" }
      total = @responses.values.size
      return 0 if total.zero?

      ((positive.to_f / total) * 100).round
    end

    def detect_critical_pain
      return nil if @responses.blank?

      @responses.each do |key, value|
        return key.to_s.humanize if value.to_s.downcase == "no" || value.to_s.downcase == "never"
      end

      nil
    end
  end
end
