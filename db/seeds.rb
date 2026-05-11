# ═══════════════════════════════════════════
# RiBuzz — Seed Completo
# ═══════════════════════════════════════════

puts "═" * 60
puts " RiBuzz Seed — Poblando base de datos..."
puts "═" * 60

# ─── Compañía Demo ──────────────────────────
demo_company = Company.create!(
  name: "RiBuzz Demo",
  industry: "SaaS",
  stage: :early_growth,
  team_size: 10
)

lead = Lead.create!(
  company: demo_company,
  full_name: "Usuario Demo",
  email: "demo@ribuzz.com",
  role: "CEO",
  password: "123456"
)
puts "✓ Usuario: demo@ribuzz.com / 123456"

# ─── Diagnóstico 1: Completado ──────────────
d1 = Diagnostic.create!(
  lead: lead,
  status: :completed,
  fit_score: 72,
  critical_pain: "Falta de proceso de ventas estructurado y seguimiento de leads",
  raw_responses: {
    problema: "Falta de crecimiento consistente en ventas",
    solucion: "Plataforma SaaS de productividad",
    cliente_ideal: "PYMEs tecnológicas 10-50 empleados",
    oferta: "Suscripción mensual con 3 planes",
    ticket_medio: 149,
    canal_principal: "Inbound marketing + referrals",
    cac_estimado: 320,
    ciclo_venta_dias: 45,
    tasa_conversion: 2.8,
    seguimiento: "Manual con spreadsheet",
    equipo_ventas: "2 SDRs, 1 closer"
  },
  commercial_inputs: {
    lead_info: {
      nombre: "Usuario Demo",
      email: "demo@ribuzz.com",
      empresa: "RiBuzz Demo",
      sector: "SaaS",
      rol: "CEO"
    },
    business_context: {
      etapa: "early_growth",
      tamano_equipo: 10,
      tiempo_operando: "2 años"
    },
    commercial_variables: {
      problema: { claridad: 4, urgencia: 5 },
      solucion: { claridad: 4, diferenciacion: 3 },
      cliente_ideal: { definicion: 3, enfoque: 2 },
      oferta: { estructura: 3, precio: 4 },
      ecuacion_valor: { claridad: 2, comunicacion: 2 },
      monetizacion: { modelo: 4, recurrencia: 5 },
      adquisicion: { diversidad: 2, escalabilidad: 3 },
      cac: { conocimiento: 2, control: 2 },
      conversion: { tasa: 2, proceso: 1 },
      seguimiento: { sistema: 1, automation: 1 },
      escalamiento: { preparacion: 2, capacidad: 2 },
      ejecucion: { consistencia: 2, metricas: 1 }
    }
  },
  commercial_outputs: {
    diagnostico_usuario: {
      contexto_empresa: "SaaS en early growth con 10 empleados y 2 años de operación. Producto validado pero crecimiento estancado.",
      diagnostico_general: "La empresa tiene un producto sólido pero carece de un sistema comercial estructurado. El proceso de ventas es artesanal y depende del fundador.",
      causa_raiz: "Ausencia de un sistema de ventas replicable. El equipo comercial opera sin métricas ni proceso definido.",
      resumen_en_una_frase: "Buen producto, equipo pequeño, pero el proceso de ventas es inexistente — crecer requiere sistema.",
      nivel_madurez_comercial: "funcional"
    },
    scoring_variables: [
      { variable: "Problema", score: 4, estado: "fuerte", weight: 3, diagnostico: "Problema claro y bien identificado en el mercado", impacto: "Impulsa crecimiento", prioridad: "baja", accion_recomendada: "Mantener el enfoque actual" },
      { variable: "Solución", score: 4, estado: "fuerte", weight: 3, diagnostico: "Solución validada con early adopters", impacto: "Impulsa crecimiento", prioridad: "baja", accion_recomendada: "Seguir iterando con feedback de clientes" },
      { variable: "ICP", score: 2, estado: "debil", weight: 3, diagnostico: "ICP no está claramente definido ni segmentado", impacto: "Genera fricción", prioridad: "alta", accion_recomendada: "Definir ICP en taller con el equipo" },
      { variable: "Oferta", score: 3, estado: "funcional", weight: 2, diagnostico: "Oferta estructurada pero sin diferenciación clara", impacto: "Genera fricción", prioridad: "media", accion_recomendada: "Trabajar propuesta de valor única" },
      { variable: "Ecuación de valor", score: 2, estado: "debil", weight: 2, diagnostico: "No comunican el valor de forma efectiva", impacto: "Genera fricción", prioridad: "alta", accion_recomendada: "Crear pitch de valor basado en resultados" },
      { variable: "Ticket medio", score: 4, estado: "fuerte", weight: 2, diagnostico: "Precio adecuado para el mercado objetivo", impacto: "Impulsa crecimiento", prioridad: "baja", accion_recomendada: "Evaluar aumento gradual" },
      { variable: "Recurrencia", score: 5, estado: "escalable", weight: 2, diagnostico: "Modelo de suscripción con retención saludable", impacto: "Impulsa crecimiento", prioridad: "baja", accion_recomendada: "Mantener foco en retención" },
      { variable: "Canal principal", score: 2, estado: "debil", weight: 3, diagnostico: "Dependencia excesiva de inbound marketing", impacto: "Bloquea ventas", prioridad: "alta", accion_recomendada: "Diversificar canales de adquisición" },
      { variable: "CAC", score: 2, estado: "debil", weight: 3, diagnostico: "CAC no medido con precisión, probablemente alto", impacto: "Bloquea ventas", prioridad: "alta", accion_recomendada: "Implementar tracking de CAC por canal" },
      { variable: "Conversión", score: 1, estado: "critico", weight: 3, diagnostico: "Tasa de conversión muy baja sin proceso definido", impacto: "Bloquea ventas", prioridad: "critica", accion_recomendada: "Diseñar pipeline de ventas con etapas claras" },
      { variable: "Seguimiento", score: 1, estado: "critico", weight: 2, diagnostico: "No hay sistema de seguimiento de leads", impacto: "Bloquea ventas", prioridad: "critica", accion_recomendada: "Implementar CRM con automatizaciones" },
      { variable: "Escalamiento", score: 2, estado: "debil", weight: 2, diagnostico: "Proceso actual no escala", impacto: "Genera fricción", prioridad: "alta", accion_recomendada: "Documentar procesos antes de contratar" },
      { variable: "Capacidad ejecución", score: 2, estado: "debil", weight: 2, diagnostico: "Ejecución inconsistente sin métricas", impacto: "Genera fricción", prioridad: "alta", accion_recomendada: "OKR semanales y revisión de pipeline" }
    ],
    diagnostico_ecuacion_valor: {
      resultado_sonado: { estado: "confuso", diagnostico: "El cliente ideal no tiene claro qué resultado concreto obtendrá" },
      probabilidad_percibida_de_logro: { estado: "media", diagnostico: "La probabilidad se percibe como moderada — falta prueba social" },
      tiempo_hasta_resultado: { estado: "medio", diagnostico: "3-4 meses para ver resultados, no está claramente comunicado" },
      esfuerzo_y_sacrificio: { estado: "medio", diagnostico: "Implementación requiere esfuerzo moderado del cliente" },
      palanca_prioritaria: "resultado_sonado",
      diagnostico_general: "La ecuación de valor está desbalanceada. El resultado soñado no está claro y la probabilidad percibida es solo media.",
      recomendacion_oferta: "Reforzar el resultado concreto en toda la comunicación. Casos de éxito detallados."
    },
    diagnostico_canal_adquisicion: {
      canal_principal: "Inbound marketing (blog + SEO + webinars)",
      dependencia: "alta",
      previsibilidad: "media",
      escalabilidad: "media",
      calidad: "alta",
      riesgo: "Cambios en algoritmo SEO o saturación del nicho",
      oportunidad: "Canal de partners y referidos completamente sin explotar",
      recomendacion: "Mantener inbound como base pero activar canal de referidos y venta directa outbound"
    },
    diagnostico_cac: {
      cac_estimado: 320,
      cac_conocido: "estimado",
      confianza_dato: "baja",
      lectura: "CAC estimado en $320, pero podría ser hasta 40% mayor al no considerar salarios completos",
      riesgo: "CAC puede estar subestimado. Riesgo de quemar caja sin detectarlo.",
      relacion_ticket_cac: 0.47,
      relacion_cac_ltv: 5.2,
      recomendacion: "Implementar tracking granular de CAC por canal antes de escalar inversión",
      prioridad: "critica"
    },
    top_3_prioridades: [
      { orden: 1, variable: "Conversión", score_actual: 1, peso_total: 4, razon: "Sin pipeline de ventas, todo lo demás es irrelevante", accion_inicial: "Diseñar pipeline de 5 etapas en CRM", metrica: "% de avance entre etapas", impacto_esperado: "Duplicar tasa de conversión en 60 días" },
      { orden: 2, variable: "Seguimiento", score_actual: 1, peso_total: 3, razon: "Los leads se pierden por falta de seguimiento sistemático", accion_inicial: "Implementar secuencia de emails automatizada", metrica: "Tiempo medio de respuesta < 2hrs", impacto_esperado: "Recuperar 30% de leads fríos" },
      { orden: 3, variable: "ICP", score_actual: 2, peso_total: 3, razon: "Sin ICP claro, el mensaje de ventas es genérico", accion_inicial: "Entrevistar a 10 mejores clientes para definir ICP", metrica: "Pipeline con 80% de deals en ICP", impacto_esperado: "Aumentar win rate en 15 puntos" }
    ],
    plan_mejora: [
      { orden: 1, variable: "Conversión", problema: "No hay pipeline definido", mejora_recomendada: "Diseñar pipeline de ventas con etapas claras", accion: "Mapear customer journey de compra", activo_necesario: "CRM (HubSpot Starter)", metrica: "% avance pipeline", horizonte: "7 dias", responsable_sugerido: "CEO + Ventas" },
      { orden: 2, variable: "Seguimiento", problema: "Leads sin seguimiento", mejora_recomendada: "Automatizar secuencia de seguimiento", accion: "Configurar emails de seguimiento automáticos", activo_necesario: "HubSpot + plantillas", metrica: "Tiempo respuesta", horizonte: "15 dias", responsable_sugerido: "SDR líder" },
      { orden: 3, variable: "CAC", problema: "CAC no medido", mejora_recomendada: "Implementar tracking de CAC", accion: "Configurar paneles de costos por canal", activo_necesario: "Dashboard en Metabase/Google Sheets", metrica: "CAC por canal", horizonte: "15 dias", responsable_sugerido: "CEO" },
      { orden: 4, variable: "ICP", problema: "ICP no definido", mejora_recomendada: "Definir ICP cuantitativo y cualitativo", accion: "Taller de definición de ICP con el equipo", activo_necesario: "Plantilla de ICP", metrica: "% deals en ICP", horizonte: "7 dias", responsable_sugerido: "CEO + Marketing" },
      { orden: 5, variable: "Canal", problema: "Dependencia de inbound", mejora_recomendada: "Activar canal de referidos", accion: "Diseñar programa de referidos", activo_necesario: "Landing page + incentivos", metrica: "Leads por referidos/mes", horizonte: "30 dias", responsable_sugerido: "Marketing" },
      { orden: 6, variable: "Ejecución", problema: "Sin métricas semanales", mejora_recomendada: "Implementar OKR comercial", accion: "Setup de OKRs y weekly review", activo_necesario: "Notion/Asana con OKRs", metrica: "% cumplimiento OKR", horizonte: "7 dias", responsable_sugerido: "CEO" }
    ],
    customer_journey: [
      { etapa: "Atraccion", objetivo: "Generar tráfico calificado", accion_cliente: "Busca soluciones en Google", accion_empresa: "Contenido SEO + webinar", activo_necesario: "Blog + Webinar mensual", metrica: "Visitas calificadas/mes", fuga_potencial: "Contenido muy genérico" },
      { etapa: "Interes", objetivo: "Capturar lead con imán de valor", accion_cliente: "Descarga recurso gratuito", accion_empresa: "Lead magnet + email sequence", activo_necesario: "Ebook/plantilla descargable", metrica: "Tasa conversión visita→lead", fuga_potencial: "Lead magnet débil" },
      { etapa: "Diagnostico", objetivo: "Calificar lead caliente", accion_cliente: "Solicita demo", accion_empresa: "Call de diagnóstico de 30min", activo_necesario: "Script de calificación", metrica: "Leads a demo", fuga_potencial: "No calificar correctamente" },
      { etapa: "Oferta", objetivo: "Presentar propuesta personalizada", accion_cliente: "Asiste a demo completa", accion_empresa: "Demo personalizada con casos de éxito", activo_necesario: "Deck presentación + casos de éxito", metrica: "Tasa demo → propuesta", fuga_potencial: "Demo muy genérica" },
      { etapa: "Seguimiento", objetivo: "Mantener caliente al prospecto", accion_cliente: "Evalúa propuesta", accion_empresa: "Email sequence post-demo", activo_necesario: "Secuencia automatizada", metrica: "Tasa de respuesta", fuga_potencial: "No dar seguimiento a tiempo" },
      { etapa: "Cierre", objetivo: "Cerrar la venta", accion_cliente: "Toma decisión de compra", accion_empresa: "Propuesta final + negociación", activo_necesario: "Contrato + propuesta comercial", metrica: "Win rate", fuga_potencial: "Objeciones no resueltas" },
      { etapa: "Entrega", objetivo: "Onboarding exitoso", accion_cliente: "Implementa la solución", accion_empresa: "Onboarding estructurado 30 días", activo_necesario: "Plan de onboarding", metrica: "Time to value", fuga_potencial: "Onboarding lento" },
      { etapa: "Recurrencia", objetivo: "Retener y expandir", accion_cliente: "Usa el producto regularmente", accion_empresa: "CSM asignado + quarterly review", activo_necesario: "CSM + dashboard de éxito", metrica: "Churn rate, NPS", fuga_potencial: "Falta de engagement" }
    ],
    output_comercial_interno: {
      lead_score: 72,
      nivel_fit: "alto",
      nivel_confianza_fit: "alto",
      estado_lead: "caliente",
      dolor_principal: "Crecimiento estancado por falta de sistema comercial",
      urgencia: "alta",
      capacidad_pago_estimado: "media",
      coachability: "alta",
      fit_marketing_tecnologia: "alto",
      servicio_recomendado_ribuzz: "diagnostico_premium",
      razon_servicio_recomendado: "La empresa tiene buen producto pero necesita sistema comercial completo",
      ticket_potencial: "$15,000 - $25,000",
      probabilidad_conversion: "alta",
      siguiente_accion_comercial: "Enviar propuesta de Diagnóstico Premium con caso de éxito similar"
    },
    recomendacion_oferta_ribuzz: {
      oferta_recomendada: "Diagnóstico Premium + Diseño de Sistema Comercial",
      justificacion: "La empresa necesita estructura comercial desde cero. Tienen el producto pero les falta el proceso.",
      entregables_sugeridos: ["Diagnóstico completo 360°", "Pipeline de ventas diseñado", "Script de ventas", "Sistema de métricas y OKR", "Plan de contratación comercial"],
      upsell_potencial: ["Implementación de CRM", "Growth Partner retenido"],
      condiciones_para_avanzar: ["Compromiso del CEO para implementación", "Dedicación de 4hrs/semana al proceso"]
    },
    decision_final: {
      decision: "Proceder con Diagnóstico Premium",
      razon: "Fit alto con el servicio. Coachabilidad alta. Dolor claro y urgencia alta.",
      proxima_accion: "Agendar call de propuesta",
      mensaje_sugerido: "Hola [Nombre], gracias por tu tiempo. Basado en nuestro diagnóstico, creo que nuestro Diagnóstico Premium es exactamente lo que necesitas para estructurar tu área comercial. ¿Agendamos 30min para revisar la propuesta?"
    }
  }
)
puts "  ✓ Diagnóstico completado con outputs comerciales"

# ─── Diagnóstico 2: En progreso ─────────────
Diagnostic.create!(
  lead: lead,
  status: :pending,
  fit_score: nil,
  critical_pain: nil,
  raw_responses: {},
  commercial_inputs: {},
  commercial_outputs: {}
)
puts "  ✓ Diagnóstico pendiente creado"

# ─── Reporte del diagnóstico ────────────────
Report.create!(
  diagnostic: d1,
  report_type: "n8n_diagnostic",
  overall_score: "moderate",
  recommendation: "diagnostico_premium",
  processed: true,
  raw_data: {
    session_id: "seed-001",
    timestamp: Time.current.iso8601,
    lead_nombre: "Usuario Demo",
    lead_correo: "demo@ribuzz.com",
    lead_empresa: "RiBuzz Demo",
    lead_sector: "SaaS",
    negocio_que_vende: "Software de productividad empresarial",
    negocio_a_quien: "PYMEs tecnológicas de 10-50 empleados",
    negocio_etapa: "early_growth",
    negocio_tiempo_operando: "2 años",
    comercial_problema_que_resuelve: "Falta de eficiencia operativa en equipos pequeños",
    comercial_solucion_actual: "Plataforma todo-en-uno con módulos configurables",
    comercial_como_lo_hacen_ahora: "Combinación de herramientas desconectadas",
    comercial_que_la_hace_unica: "Simplicidad de implementación y UX superior",
    comercial_por_que_te_comprarian: "Porque necesitan una solución integrada",
    comercial_quien_compra: "CTO/CEO de PYME tecnológica",
    comercial_como_lo_conocen: "Google, blogs, referidos",
    comercial_ticket_promedio: 149,
    comercial_ciclo_venta_dias: 45,
    comercial_tasa_conversion: 2.8,
    comercial_clientes_actuales: 85,
    comercial_leads_mes: 320,
    comercial_ventas_mes: 9,
    comercial_inversion_mes: 4500,
    scoring_promedio: 3.2,
    scoring_criticos: "Conversión, Seguimiento",
    scoring_variables: { conversion: 1, seguimiento: 1, icp: 2, ecuacion_valor: 2, cac: 2, canal: 2 },
    salud_comercial: "En riesgo — buen producto pero proceso de ventas inexistente",
    fit_decision: "Alto fit — proceder con diagnóstico premium",
    fit_nivel: "alto",
    alerta_lista: [
      { tipo: "critica", mensaje: "Tasa de conversión por debajo del 3%", variable: "conversion" },
      { tipo: "critica", mensaje: "No hay sistema de seguimiento de leads", variable: "seguimiento" },
      { tipo: "alta", mensaje: "CAC no medido con precisión", variable: "cac" }
    ]
  },
  scoring: {
    score_promedio_n8n: 3.2,
    score_sintetico: 62,
    overall_score: 6.2,
    overall_label: "moderate",
    nivel_madurez: "funcional",
    causa_raiz: "Ausencia de sistema de ventas estructurado",
    recomendacion: "diagnostico_premium",
    confidence: 78,
    breakdown: {
      mercado: { label: "Mercado y Posicionamiento", score: 7 },
      dolor: { label: "Dolor y Propuesta de Valor", score: 6 },
      oferta: { label: "Oferta y Precio", score: 7 },
      cliente: { label: "Cliente Ideal", score: 4 },
      canal: "inbound",
      prioridades: [
        { posicion: 1, variable: "Conversión", razon: "Tasa de conversión crítica", impacto: "Alto", metrica: "Pasar de 2.8% a >8%" },
        { posicion: 2, variable: "Seguimiento", razon: "Leads sin seguimiento", impacto: "Alto", metrica: "Implementar CRM" },
        { posicion: 3, variable: "ICP", razon: "ICP no definido", impacto: "Medio", metrica: "Pipeline enfocado 80%" }
      ],
      quick_wins: { label: "Implementar CRM gratuito", impacto: "Alto", esfuerzo: "Bajo" },
      customer_journey: { completo: false, etapa_fuga: "seguimiento" },
      plan_mejora: { acciones: 6, horizonte: "60 días" }
    },
    metricas_financieras: {
      ticket_medio: "$149/mes",
      cac: "$320 (estimado)",
      ltv: "$1,664",
      factor_recurrencia: "14 meses",
      ratio_cac_ticket: "2.15x",
      ratio_cac_ltv: "5.2x",
      leads_perdidos: "68%",
      ingreso_potencial: "$47,680/año",
      inversion_mes: "$4,500",
      leads_mes: "320",
      ventas_mes: "9",
      clientes_actuales: "85",
      clientes_nuevos_mes: "9",
      recurrencia: "92% mensual"
    }
  }
)
puts "  ✓ Reporte creado con scoring completo"

# ─── Plan Estratégico ─────────────────────
sp1 = StrategyPlan.create!(
  diagnostic: d1,
  executive_summary: "RiBuzz Demo necesita transformar su operación comercial de artesanal a sistemática. Este plan detalla los pasos para duplicar la tasa de conversión, implementar un CRM con automatizaciones, definir el ICP, y diversificar canales de adquisición en los próximos 60 días.",
  audio_briefing_url: nil,
  kpis: [
    { name: "Tasa de Conversión", target: "8%", current: "2.8%", metric: "% de leads que se convierten en clientes" },
    { name: "Tiempo de Seguimiento", target: "< 2hrs", current: "24-48hrs", metric: "Tiempo entre lead y primer contacto" },
    { name: "CAC", target: "$250", current: "$320", metric: "Costo de adquisición por cliente" },
    { name: "Pipeline Coverage", target: "4x", current: "1.5x", metric: "Valor pipeline / cuota" },
    { name: "Leads Calificados/mes", target: "50", current: "25", metric: "Leads que cumplen ICP" }
  ],
  okrs: [
    {
      objective: "Estructurar proceso comercial replicable",
      key_results: ["Pipeline de 5 etapas documentado y activo", "CRM implementado con todas las integraciones", "3 SDRs entrenados en el nuevo proceso", "Tasa de conversión > 5%"]
    },
    {
      objective: "Mejorar calidad y velocidad de seguimiento",
      key_results: ["Email sequence automatizada de 5 pasos", "Tiempo medio de respuesta < 2 horas", "Tasa de recuperación de leads fríos > 20%"]
    },
    {
      objective: "Diversificar canales de adquisición",
      key_results: ["Programa de referidos lanzado", "Canal outbound generando 10 leads/mes", "Dependencia de inbound < 60%"]
    }
  ]
)
puts "  ✓ Plan estratégico con KPIs y OKRs"

# ─── Journey Stages ─────────────────────────
JourneyStage.create!([
  {
    strategy_plan: sp1,
    stage_name: "Atracción",
    description: "Generar tráfico calificado y captar leads con contenido de valor orientado a PYMEs tecnológicas",
    action_items: ["Publicar 8 artículos SEO/mes enfocados en dolor de cliente", "Webinar mensual con caso de éxito", "Lead magnet: 'Guía de crecimiento comercial para SaaS'"],
    order: 1
  },
  {
    strategy_plan: sp1,
    stage_name: "Interés",
    description: "Nutrir leads con secuencia automatizada que eduque y demuestre valor",
    action_items: ["Email sequence de 5 emails con caso de éxito", "Segmentar leads por industria y tamaño", "Retargeting para leads que no abren emails"],
    order: 2
  },
  {
    strategy_plan: sp1,
    stage_name: "Diagnóstico",
    description: "Calificar leads calientes con call de 30 minutos para identificar fit",
    action_items: ["Script de calificación BANT", "CRM con campos de calificación obligatorios", "Roadmap de calificación: frío → tibio → caliente"],
    order: 3
  },
  {
    strategy_plan: sp1,
    stage_name: "Oferta",
    description: "Demo personalizada mostrando valor concreto para el prospecto",
    action_items: ["Deck de demo con sección personalizable", "Casos de éxito por industria", "Propuesta comercial estándar con 3 opciones"],
    order: 4
  },
  {
    strategy_plan: sp1,
    stage_name: "Seguimiento",
    description: "Mantener al prospecto caliente con seguimiento sistemático",
    action_items: ["Email sequence post-demo (3 emails)", "Video personalizado de seguimiento", "Conectar en LinkedIn y compartir contenido relevante"],
    order: 5
  },
  {
    strategy_plan: sp1,
    stage_name: "Cierre",
    description: "Cerrar la venta con propuesta clara y manejo de objeciones",
    action_items: ["Plantilla de propuesta comercial", "Guía de manejo de objeciones", "Checklist de cierre con decisor final"],
    order: 6
  },
  {
    strategy_plan: sp1,
    stage_name: "Onboarding",
    description: "Garantizar tiempo-to-valor rápido con onboarding estructurado",
    action_items: ["Plan de onboarding 30 días con milestones", "CSM asignado desde el día 1", "Webinar de bienvenida semanal"],
    order: 7
  },
  {
    strategy_plan: sp1,
    stage_name: "Expansión",
    description: "Retener y expander la cuenta con revisiones periódicas",
    action_items: ["Quarterly business review con KPIs", "Programa de referidos para clientes activos", "Detección temprana de churn con alerts automáticos"],
    order: 8
  }
])
puts "  ✓ 8 etapas del journey creadas"

# ═══════════════════════════════════════════
# TECH CORP — Seed Original Mejorado
# ═══════════════════════════════════════════

tech_company = Company.create!(
  name: "TechCorp",
  industry: "SaaS",
  stage: :early_growth,
  team_size: 25
)

tech_lead = Lead.create!(
  company: tech_company,
  full_name: "Carlos Mendoza",
  email: "carlos@techcorp.com",
  role: "CEO",
  password: "123456"
)

tech_diag = Diagnostic.create!(
  lead: tech_lead,
  status: :completed,
  fit_score: 78,
  critical_pain: "Falta de proceso de ventas estructurado",
  raw_responses: {
    problema: "Dificultad para escalar ventas B2B",
    solucion: "Plataforma SaaS enterprise",
    cliente_ideal: "Empresas 50-200 empleados",
    oferta: "Suscripción anual 3 planes",
    ticket_medio: 899,
    canal_principal: "Ventas directas + consultores",
    cac_estimado: 2800,
    ciclo_venta_dias: 75,
    tasa_conversion: 5.2,
    seguimiento: "CRM con automatización básica"
  },
  commercial_outputs: {
    diagnostico_usuario: {
      contexto_empresa: "SaaS enterprise con 25 empleados, ventas directas a empresas 50-200 empleados.",
      diagnostico_general: "Empresa con buen proceso de ventas pero sobrevende a cuentas que no son su ICP óptimo.",
      causa_raiz: "ICP demasiado amplio y equipo de ventas sin foco",
      resumen_en_una_frase: "Venden bien pero al cliente equivocado.",
      nivel_madurez_comercial: "fuerte"
    },
    scoring_variables: [
      { variable: "Problema", score: 5, estado: "escalable", weight: 3, diagnostico: "Problema claro y urgente en el mercado", impacto: "Impulsa crecimiento", prioridad: "baja", accion_recomendada: "Mantener enfoque" },
      { variable: "Solución", score: 4, estado: "fuerte", weight: 3, diagnostico: "Solución robusta con tracción en mercado", impacto: "Impulsa crecimiento", prioridad: "baja", accion_recomendada: "Seguir mejorando" },
      { variable: "ICP", score: 3, estado: "funcional", weight: 3, diagnostico: "ICP definido pero no se respeta consistentemente", impacto: "Genera fricción", prioridad: "media", accion_recomendada: "Reforzar disciplina de ICP" }
    ],
    output_comercial_interno: {
      lead_score: 78,
      nivel_fit: "alto",
      estado_lead: "caliente",
      coachability: "media",
      servicio_recomendado_ribuzz: "diseno_sistema_comercial"
    }
  }
)

StrategyPlan.create!(
  diagnostic: tech_diag,
  executive_summary: "TechCorp necesita refinar su ICP y especializar su fuerza de ventas.",
  kpis: [
    { name: "Win rate por segmento", target: "25%", current: "18%" },
    { name: "Ciclo de venta", target: "45 días", current: "75 días" }
  ],
  okrs: [
    { objective: "Focalizar ventas en ICP óptimo", key_results: ["Pipeline con 90% en ICP", "Win rate > 22%", "Ciclo < 55 días"] }
  ]
)

puts ""
puts "═" * 60
puts " Seed completado:"
puts "   • #{Company.count} empresas"
puts "   • #{Lead.count} leads"
puts "   • #{Diagnostic.count} diagnósticos"
puts "   • #{Report.count} reportes"
puts "   • #{StrategyPlan.count} planes estratégicos"
puts "   • #{JourneyStage.count} etapas de journey"
puts "═" * 60