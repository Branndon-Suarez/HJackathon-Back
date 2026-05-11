module Api
  module V1
    class DiagnosticsController < ApplicationController
      rescue_from InvalidTransitionError do |e|
        render json: {
          error: {
            code: ErrorCodes::CONFLICT,
            message: e.message,
            status: 422,
            details: [ { field: :status, message: "cannot transition from completed to pending" } ]
          }
        }, status: :unprocessable_content
      end

      before_action :set_lead, only: %i[index create]
      before_action :set_diagnostic, only: %i[show update ribuzz_diagnostic]

      def index
        diagnostics = @lead.diagnostics.ordered.page(params[:page]).per(params[:per] || 10)
        render json: {
          data: DiagnosticSerializer.render_as_hash(diagnostics, view: :extended),
          meta: pagination_meta(diagnostics)
        }
      end

      def show
        render json: { data: DiagnosticSerializer.render_as_hash(@diagnostic, view: :extended) }
      end

      def create
        diagnostic = @lead.diagnostics.create!(diagnostic_params)
        Diagnostics::ProcessService.new(diagnostic).call if diagnostic.completed?
        render json: { data: DiagnosticSerializer.render_as_hash(diagnostic) }, status: :created
      end

      def ribuzz_diagnostic
        # Ensure commercial_inputs is populated from raw_responses if empty
        map_raw_responses_to_commercial_inputs if @diagnostic.commercial_inputs.blank?
        RiBuzz::DiagnosticService.new(@diagnostic).call
        render json: { data: DiagnosticSerializer.render_as_hash(@diagnostic, view: :extended) }
      end

      def update
        validate_status_transition if params[:diagnostic][:status].present?

        # Merge raw_responses instead of overwriting
        if params[:diagnostic][:raw_responses].present?
          existing = @diagnostic.raw_responses || {}
          incoming = params[:diagnostic].delete(:raw_responses)
          merged = existing.deep_merge(incoming)
          params[:diagnostic][:raw_responses] = merged
        end

        @diagnostic.update!(diagnostic_params)

        # Map to commercial_inputs when completed
        if @diagnostic.completed? && @diagnostic.commercial_inputs.blank?
          map_raw_responses_to_commercial_inputs
          @diagnostic.save!
        end

        Diagnostics::ProcessService.new(@diagnostic).call if @diagnostic.previous_changes.key?("status")

        render json: { data: DiagnosticSerializer.render_as_hash(@diagnostic) }
      end

      private

      def set_lead
        @lead = Lead.find(params[:lead_id])
      end

      def set_diagnostic
        @diagnostic = Diagnostic.find(params[:id])
      end

      def diagnostic_params
        params.require(:diagnostic).permit(
          :status, :fit_score, :critical_pain,
          raw_responses: {},
          commercial_inputs: {}
        )
      end

      # Map frontend form structure to backend commercial_inputs format
      def map_raw_responses_to_commercial_inputs
        raw = @diagnostic.raw_responses || {}
        lead_info = raw.dig("lead") || raw.dig(:lead) || {}
        variables = raw.dig("variables") || raw.dig(:variables) || {}

        # Flatten any step-level wrappers
        if lead_info.blank? && raw.keys.any? { |k| k.to_s.start_with?("step_") }
          # The data is nested under step keys, collect all
          all_lead = {}
          all_vars = {}
          raw.each do |key, val|
            next unless key.to_s.start_with?("step_")
            step_lead = val["lead"] || val[:lead] || {}
            step_vars = val["variables"] || val[:variables] || {}
            all_lead.merge!(step_lead)
            all_vars.deep_merge!(step_vars)
          end
          lead_info = all_lead
          variables = all_vars
        end

        mapped = {
          lead: {
            nombre_usuario: lead_info["nombre_usuario"] || lead_info[:nombre_usuario],
            correo: lead_info["correo"] || lead_info[:correo],
            telefono: lead_info["telefono"] || lead_info[:telefono],
            empresa: lead_info["empresa"] || lead_info[:empresa],
            sector: lead_info["sector"] || lead_info[:sector],
            web: lead_info["web"] || lead_info[:web]
          },
          business_context: {
            descripcion_empresa: lead_info["empresa"] || lead_info[:empresa] || "",
            sector: lead_info["sector"] || lead_info[:sector] || "",
            etapa_actual: variables.dig("problema", "urgencia") || variables.dig(:problema, :urgencia) || "operacion"
          },
          commercial_variables: {
            problema: {
              problema_que_resuelve: variables.dig("problema", "problema_que_resuelve") || variables.dig(:problema, :problema_que_resuelve),
              urgencia_del_problema: map_urgencia(variables.dig("problema", "urgencia") || variables.dig(:problema, :urgencia))
            },
            solucion: {
              descripcion_solucion: variables.dig("solucion", "mecanismo_unico") || variables.dig(:solucion, :mecanismo_unico),
              diferenciador: variables.dig("solucion", "diferenciador") || variables.dig(:solucion, :diferenciador),
              evidencia_de_resultado: variables.dig("solucion", "evidencia") || variables.dig(:solucion, :evidencia)
            },
            cliente: {
              cliente_ideal_actual: variables.dig("cliente", "cliente_ideal") || variables.dig(:cliente, :cliente_ideal),
              decisor_de_compra: variables.dig("cliente", "decisor") || variables.dig(:cliente, :decisor),
              cliente_no_fit: variables.dig("cliente", "cliente_no_fit") || variables.dig(:cliente, :cliente_no_fit),
              dolores_del_cliente: [
                variables.dig("cliente", "cliente_ideal") || variables.dig(:cliente, :cliente_ideal)
              ].compact
            },
            oferta: {
              oferta_actual: variables.dig("oferta", "promesa_principal") || variables.dig(:oferta, :promesa_principal),
              promesa_principal: variables.dig("oferta", "promesa_principal") || variables.dig(:oferta, :promesa_principal),
              nivel_claridad_oferta: variables.dig("oferta", "promesa_principal").present? ? "alto" : "bajo",
              objeciones_frecuentes: []
            },
            ecuacion_valor_hormozi: {
              resultado_sonado: variables.dig("ecuacion_valor_hormozi", "resultado_sonado") || variables.dig(:ecuacion_valor_hormozi, :resultado_sonado),
              probabilidad_percibida_de_logro: "media",
              palanca_mas_debil: variables.dig("ecuacion_valor_hormozi", "esfuerzo") || variables.dig(:ecuacion_valor_hormozi, :esfuerzo)
            },
            monetizacion: {
              ticket_medio: variables.dig("monetizacion", "ticket_medio") || variables.dig(:monetizacion, :ticket_medio),
              ventas_mensuales_aproximadas: variables.dig("monetizacion", "facturacion_mensual") || variables.dig(:monetizacion, :facturacion_mensual),
              recurrencia: variables.dig("monetizacion", "recurrencia") || variables.dig(:monetizacion, :recurrencia)
            },
            adquisicion: {
              canal_principal_adquisicion: {
                canal: variables.dig("adquisicion", "canal_principal") || variables.dig(:adquisicion, :canal_principal),
                escalabilidad: map_scalability(variables.dig("adquisicion", "predictibilidad") || variables.dig(:adquisicion, :predictibilidad))
              }
            },
            cac: {
              cac_conocido: map_cac_knowledge(variables.dig("cac", "conoce_cac") || variables.dig(:cac, :conoce_cac)),
              inversion_marketing_mensual: variables.dig("cac", "inversion_marketing") || variables.dig(:cac, :inversion_marketing),
              clientes_nuevos_mensuales: variables.dig("cac", "clientes_nuevos") || variables.dig(:cac, :clientes_nuevos)
            },
            conversion: {
              conversion_aproximada: variables.dig("conversion", "tasa_conversion") || variables.dig(:conversion, :tasa_conversion),
              leads_mensuales: variables.dig("conversion", "leads_mensuales") || variables.dig(:conversion, :leads_mensuales),
              tiempo_cierre_dias: variables.dig("conversion", "tiempo_cierre") || variables.dig(:conversion, :tiempo_cierre)
            },
            seguimiento: {
              uso_crm_o_base_de_datos: map_crm_usage(variables.dig("seguimiento", "usa_crm") || variables.dig(:seguimiento, :usa_crm)),
              tiempo_respuesta_inicial: variables.dig("seguimiento", "tiempo_respuesta") || variables.dig(:seguimiento, :tiempo_respuesta),
              intentos_seguimiento: variables.dig("seguimiento", "intentos_seguimiento") || variables.dig(:seguimiento, :intentos_seguimiento)
            },
            escalamiento: {
              dependencia_del_fundador: map_dependency(variables.dig("escalamiento", "dependencia_fundador") || variables.dig(:escalamiento, :dependencia_fundador)),
              procesos_documentados: variables.dig("escalamiento", "procesos_documentados") || variables.dig(:escalamiento, :procesos_documentados),
              cuello_de_botella: variables.dig("escalamiento", "cuello_botella") || variables.dig(:escalamiento, :cuello_botella)
            }
          },
          fit_ribuzz: {
            urgencia: map_urgencia(variables.dig("problema", "urgencia") || variables.dig(:problema, :urgencia)),
            willingness_to_pay: variables.dig("monetizacion", "ticket_medio").present? ? "alta" : "media",
            coachability: "media",
            capacidad_de_ejecucion_cliente: map_execution(variables.dig("escalamiento", "dependencia_fundador") || variables.dig(:escalamiento, :dependencia_fundador)),
            fit_marketing_tecnologia: "medio"
          }
        }

        @diagnostic.commercial_inputs = mapped
      end

      def map_urgencia(val)
        return "alta" if val.to_s.downcase.in?(%w[alta crítica crítico])
        return "media" if val.to_s.downcase == "media"
        return "baja" if val.to_s.downcase == "baja"
        "media"
      end

      def map_scalability(val)
        return "alta" if val.to_s.downcase.include?("máquina")
        return "media" if val.to_s.downcase.include?("veces")
        return "baja" if val.to_s.downcase.include?("suerte")
        "media"
      end

      def map_cac_knowledge(val)
        return "si" if val.to_s.downcase.include?("exacto")
        return "estimado" if val.to_s.downcase.include?("estimo")
        "no"
      end

      def map_crm_usage(val)
        return "si" if val.to_s.downcase.include?("profesional")
        return "parcial" if val.to_s.downcase.include?("excel") || val.to_s.downcase.include?("notion")
        "no"
      end

      def map_dependency(val)
        num = val.to_s.to_i
        return "alta" if num >= 7
        return "media" if num >= 4
        "baja"
      end

      def map_execution(val)
        num = val.to_s.to_i
        return "baja" if num >= 7
        return "media" if num >= 4
        "alta"
      end

      def validate_status_transition
        new_status = params[:diagnostic][:status].to_s
        return unless @diagnostic.completed? && new_status == "pending"

        raise InvalidTransitionError, "Cannot revert a completed diagnostic back to pending"
      end

      def pagination_meta(collection)
        {
          current_page: collection.current_page,
          next_page: collection.next_page,
          prev_page: collection.prev_page,
          total_pages: collection.total_pages,
          total_count: collection.total_count
        }
      end
    end
  end
end