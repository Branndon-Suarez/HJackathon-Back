require "rails_helper"

RSpec.describe Reports::ScoringService do
  let(:payload) do
    {
      "session_id" => "test-session-001",
      "timestamp" => "2026-05-11T15:30:00Z",
      "confianza_datos" => "alta",
      "lead_nombre" => "Juan Pérez",
      "lead_correo" => "juan@empresa.com",
      "lead_empresa" => "Acme Corp",
      "lead_sector" => "SaaS",
      "negocio_que_vende" => "Software de gestión",
      "negocio_a_quien" => "PYMEs",
      "negocio_etapa" => "crecimiento",
      "negocio_tiempo_operando" => "3 años",
      "negocio_tamano_equipo" => "15",
      "comercial_problema" => "No tienen visibilidad de su pipeline",
      "comercial_problema_impacto" => "Alto - pierden deals sin saber por qué",
      "comercial_solucion" => "Dashboard con pipeline inteligente",
      "comercial_diferenciador" => "IA predictiva integrada",
      "comercial_cliente_real" => "Gerentes comerciales en PYMEs tech",
      "comercial_cliente_icp" => "Empresas SaaS B2B 1-50 empleados",
      "comercial_decisor" => "CEO / Head of Sales",
      "comercial_oferta" => "Plataforma SaaS con onboarding incluido",
      "comercial_precio" => "$150-500/mes según módulos",
      "comercial_resultado_prometido" => "30% más conversiones en 90 días",
      "comercial_cta" => "Demo personalizada de 30 min",
      "comercial_objeciones" => "Precio, migración de datos, integración",
      "comercial_tasa_conversion" => "12",
      "comercial_seguimiento_proceso" => "Sí - CRM HubSpot",
      "comercial_dependencia_fundador" => "Media",
      "comercial_herramientas" => "HubSpot, Slack, Notion",
      "comercial_inversion_mes" => "2000",
      "comercial_leads_mes" => "80",
      "comercial_ventas_mes" => "25",
      "comercial_recurrencia" => "suscripcion",
      "comercial_canal_principal" => "Inbound - Content Marketing",
      "comercial_canal_previsibilidad" => "Media-Alta",
      "metrica_ticket_medio" => "350",
      "metrica_cac" => "120",
      "metrica_ltv" => "4200",
      "metrica_factor_recurrencia" => "12",
      "metrica_ratio_cac_ticket" => "0.34",
      "metrica_ratio_cac_ltv" => "0.029",
      "scoring_score_promedio" => 7.5,
      "scoring_variables" => {
        "fit" => 8,
        "pain_level" => 7,
        "budget_availability" => 6,
        "decision_making_speed" => 7,
        "market_timing" => 8
      },
      "scoring_nivel_madurez_comercial" => "intermedio",
      "scoring_causa_raiz" => "Falta de proceso comercial definido"
    }
  end

  describe "#call" do
    subject { described_class.new(payload).call }

    it "returns overall_score" do
      expect(subject[:overall_score]).to be_a(Float)
      expect(subject[:overall_score]).to be_between(1.0, 5.0)
    end

    it "returns overall_label" do
      expect(subject[:overall_label]).to be_in(%w[excellent good moderate poor critical])
    end

    it "returns dimensions" do
      expect(subject[:dimensions]).to be_a(Array)
      expect(subject[:dimensions].size).to be > 0
      expect(subject[:dimensions].first).to include(:variable, :score, :estado, :weight)
    end

    it "returns recommendation" do
      expect(subject[:recommendation]).to be_present
    end

    it "returns financial_metrics_summary" do
      expect(subject[:financial_metrics_summary][:ticket_medio]).to eq("350")
      expect(subject[:financial_metrics_summary][:cac]).to eq("120")
    end

    context "with empty scores" do
      let(:payload) { { "session_id" => "empty" } }

      it "returns low scores" do
        expect(subject[:overall_score]).to be <= 2.0
        expect(subject[:overall_label]).to eq("critical")
      end
    end

    context "with high scores" do
      before do
        payload["scoring"] = { "variables" => { "fit" => 10, "pain_level" => 9, "budget_availability" => 9 } }
      end

      it "classifies as excellent or good" do
        expect(subject[:overall_score]).to be >= 3.0
      end
    end
  end
end