module StrategyPlans
  class GenerateService
    def initialize(diagnostic)
      @diagnostic = diagnostic
    end

    def call
      raise "Diagnostic must be completed" unless @diagnostic.completed?

      plan = ActiveRecord::Base.transaction do
        @diagnostic.create_strategy_plan!(
          executive_summary: build_summary,
          kpis: [],
          okrs: []
        )
      end

      plan
    end

    private

    def build_summary
      "Strategy plan based on diagnostic ##{@diagnostic.id} " \
        "(fit score: #{@diagnostic.fit_score}, " \
        "critical pain: #{@diagnostic.critical_pain})"
    end
  end
end
