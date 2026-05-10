module RiBuzz
  class ImprovementPlanGenerator
    def initialize(scoring_result, commercial_inputs)
      @scoring = scoring_result
      @inputs = commercial_inputs.with_indifferent_access
    end

    def call
      weak_variables = @scoring[:scores].select { |s| s[:score] <= 3 }
                                          .sort_by { |s| s[:score] }

      weak_variables.each_with_index.map do |var, i|
        build_action(var, i + 1)
      end
    end

    private

    def build_action(var, order)
      variable_key = find_key(var[:variable])
      {
        orden: order,
        variable: var[:variable],
        problema: var[:diagnostico] || "#{var[:variable]} en estado #{var[:estado]} (score: #{var[:score]}/5)",
        mejora_recomendada: recommended_improvement(var[:variable]),
        accion: specific_action(var[:variable]),
        activo_necesario: required_asset(var[:variable]),
        metrica: metric(var[:variable]),
        horizonte: horizon(var[:variable], var[:score]),
        responsable_sugerido: suggested_role(var[:variable])
      }
    end

    def find_key(label)
      RiBuzz::ScoringService::SCORING_RULES.each do |key, rule|
        return key if rule[:label] == label
      end
      nil
    end

    def recommended_improvement(variable)
      improvements = {
        "Oferta" => "Estructurar oferta con promesa clara, entregables definidos y CTA específico",
        "Conversión" => "Diseñar pipeline de conversión con etapas, tiempos y activos por etapa",
        "Seguimiento" => "Implementar sistema de seguimiento multicanal con CRM",
        "CAC" => "Desglosar costos de adquisición y optimizar canales por rentabilidad",
        "Canal principal de adquisición" => "Diversificar canales y hacer predecible la adquisición",
        "Ecuación de valor" => "Fortalecer oferta desde la palanca más débil de la ecuación",
        "ICP" => "Definir ICP con datos de clientes actuales y ajustar targeting",
        "Ticket medio" => "Evaluar precios, empaquetado y venta adicional",
        "Recurrencia" => "Diseñar modelo de ingresos recurrentes",
        "Solución" => "Clarificar mecanismo de solución y evidenciar resultado",
        "Problema" => "Precisar el problema y aumentar urgencia percibida",
        "Cliente actual" => "Segmentar y priorizar clientes por rentabilidad",
        "Escalamiento" => "Documentar procesos y delegar operación comercial",
        "Etapa del negocio" => "Validar supuestos antes de escalar",
        "Capacidad de ejecución" => "Liberar capacidad con automatización y delegación"
      }
      improvements[variable] || "Mejorar #{variable.downcase}"
    end

    def specific_action(variable)
      actions = {
        "Oferta" => "Redactar promesa principal, definir entregables, fijar precio y crear CTA",
        "Conversión" => "Mapear etapas actuales, identificar fugas, crear activo por etapa",
        "Seguimiento" => "Configurar CRM, definir secuencia de seguimiento, automatizar recordatorios",
        "CAC" => "Listar todos los costos de adquisición del último mes, calcular CAC real",
        "Canal principal de adquisición" => "Identificar métricas del canal principal, probar 1 canal alternativo",
        "Ecuación de valor" => "Analizar las 4 palancas, fortalecer la más débil con evidencia o rediseño",
        "ICP" => "Entrevistar 3 clientes actuales, documentar perfil común, crear ICP escrito",
        "Ticket medio" => "Analizar precios actuales, crear 3 opciones de empaquetado",
        "Recurrencia" => "Diseñar programa de recompra, suscripción o mantenimiento",
        "Solución" => "Documentar caso de éxito, crear one-pager de solución",
        "Problema" => "Entrevistar 3 clientes sobre el problema, documentar impacto real",
        "Cliente actual" => "Segmentar base de clientes actual por ticket y recurrencia",
        "Escalamiento" => "Documentar proceso de ventas actual en un flowchart",
        "Etapa del negocio" => "Definir 3 supuestos críticos a validar",
        "Capacidad de ejecución" => "Identificar 3 tareas delegables y asignarlas esta semana"
      }
      actions[variable] || "Ejecutar mejora para #{variable.downcase}"
    end

    def required_asset(variable)
      assets = {
        "Oferta" => "Página de venta o landing page",
        "Conversión" => "Pipeline en CRM, activo de conversión por etapa",
        "Seguimiento" => "CRM o herramienta de seguimiento",
        "CAC" => "Hoja de cálculo de costos",
        "Canal principal de adquisición" => "Dashboard de métricas por canal",
        "Ecuación de valor" => "Documento de propuesta de valor",
        "ICP" => "Perfil de cliente ideal documentado",
        "Ticket medio" => "Matriz de precios y empaquetado",
        "Recurrencia" => "Programa de fidelización o suscripción",
        "Solución" => "Caso de éxito o testimonial",
        "Problema" => "Documento de investigación de clientes",
        "Cliente actual" => "Base de datos segmentada",
        "Escalamiento" => "Manual de procesos comerciales",
        "Etapa del negocio" => "Canvas de modelo de negocio",
        "Capacidad de ejecución" => "Herramienta de gestión de tareas"
      }
      assets[variable] || "Activo por definir"
    end

    def metric(variable)
      metrics = {
        "Oferta" => "Tasa de conversión",
        "Conversión" => "% conversión por etapa",
        "Seguimiento" => "Tasa de respuesta",
        "CAC" => "CAC mensual",
        "Canal principal de adquisición" => "Clientes nuevos por canal",
        "Ecuación de valor" => "Percepción de valor",
        "ICP" => "% clientes ICP",
        "Ticket medio" => "Ticket promedio",
        "Recurrencia" => "Tasa de recompra",
        "Solución" => "Satisfacción cliente",
        "Problema" => "Urgencia percibida",
        "Cliente actual" => "Churn rate",
        "Escalamiento" => "Ventas sin fundador",
        "Etapa del negocio" => "Ingresos mensuales",
        "Capacidad de ejecución" => "% tareas completadas"
      }
      metrics[variable] || "Métrica por definir"
    end

    def horizon(variable, score)
      return "7 dias" if score <= 2
      return "15 dias" if score == 3
      "30 dias"
    end

    def suggested_role(variable)
      roles = {
        "Oferta" => "Fundador / CEO",
        "Conversión" => "Director Comercial",
        "Seguimiento" => "Ejecutivo de Ventas",
        "CAC" => "Gerente de Marketing",
        "Canal principal de adquisición" => "Gerente de Marketing",
        "Ecuación de valor" => "Fundador / CEO",
        "ICP" => "Director Comercial",
        "Ticket medio" => "Fundador / CEO",
        "Recurrencia" => "Director Comercial",
        "Solución" => "Fundador / CEO",
        "Problema" => "Fundador / CEO",
        "Cliente actual" => "Director Comercial",
        "Escalamiento" => "Fundador / CEO",
        "Etapa del negocio" => "Fundador / CEO",
        "Capacidad de ejecución" => "Gerente de Operaciones"
      }
      roles[variable] || "Equipo comercial"
    end
  end
end
