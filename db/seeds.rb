company = Company.create!(
  name: "TechCorp",
  industry: "SaaS",
  stage: :early_growth,
  team_size: 25
)

lead = Lead.create!(
  company: company,
  full_name: "Carlos Mendoza",
  email: "carlos@techcorp.com",
  role: "CEO"
)

diagnostic = Diagnostic.create!(
  lead: lead,
  status: :completed,
  raw_responses: {
    q1: "Si",
    q2: "No",
    q3: "Tal vez"
  },
  fit_score: 78,
  critical_pain: "Falta de proceso de ventas estructurado"
)

strategy_plan = StrategyPlan.create!(
  diagnostic: diagnostic,
  executive_summary: "TechCorp necesita implementar un CRM y definir un proceso de ventas B2B.",
  audio_briefing_url: "https://storage.supabase.co/audio/techcorp-summary.mp3",
  kpis: [
    { name: "Tasa de conversión", target: "15%" },
    { name: "Ciclo de venta promedio", target: "45 días" }
  ],
  okrs: [
    { objective: "Estructurar proceso comercial", key_results: ["CRM implementado", "3 SDRs entrenados"] }
  ]
)

JourneyStage.create!([
  {
    strategy_plan: strategy_plan,
    stage_name: "Consciencia",
    description: "Atraer tráfico calificado con contenido educativo",
    action_items: ["Publicar 4 artículos blog/mes", "Webinars semanales"],
    order: 1
  },
  {
    strategy_plan: strategy_plan,
    stage_name: "Consideración",
    description: "Nutrir leads con casos de éxito",
    action_items: ["Email sequence de 5 pasos", "Demo personalizada"],
    order: 2
  },
  {
    strategy_plan: strategy_plan,
    stage_name: "Conversión",
    description: "Cierre con propuesta de valor clara",
    action_items: ["Propuesta comercial estándar", "Call con decisor final"],
    order: 3
  },
  {
    strategy_plan: strategy_plan,
    stage_name: "Retención",
    description: "Onboarding y éxito del cliente",
    action_items: ["Plan de onboarding 30 días", "CSM asignado"],
    order: 4
  },
  {
    strategy_plan: strategy_plan,
    stage_name: "Referido",
    description: "Programa de referidos",
    action_items: ["Incentivo por referido", "NPS trimestral"],
    order: 5
  }
])

puts "Seed completado: #{Company.count} empresa, #{Lead.count} lead, #{Diagnostic.count} diagnóstico, #{StrategyPlan.count} plan, #{JourneyStage.count} etapas"
