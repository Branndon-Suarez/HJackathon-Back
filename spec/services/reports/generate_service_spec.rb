require "rails_helper"

RSpec.describe Reports::GenerateService do
  let(:company) { create(:company) }
  let(:lead) { create(:lead, company: company) }
  let(:session_id) { "session-#{SecureRandom.hex(4)}" }
  let!(:diagnostic) { create(:diagnostic, lead: lead, session_id: session_id, status: :completed) }

  let(:payload) do
    {
      "session_id" => session_id,
      "lead_nombre" => "Juan Pérez",
      "lead_correo" => "juan@empresa.com",
      "lead_empresa" => "Acme Corp",
      "negocio_que_vende" => "Software",
      "negocio_etapa" => "crecimiento",
      "comercial_problema" => "No tienen visibilidad del pipeline",
      "comercial_problema_impacto" => "Alto",
      "comercial_oferta" => "Plataforma SaaS",
      "comercial_diferenciador" => "IA predictiva",
      "comercial_cliente_real" => "Gerentes comerciales",
      "comercial_cliente_icp" => "PYMEs tech",
      "comercial_decisor" => "CEO",
      "comercial_precio" => "$300/mes",
      "comercial_resultado_prometido" => "30% más conversiones",
      "comercial_cta" => "Demo 30 min",
      "comercial_tasa_conversion" => "12",
      "comercial_recurrencia" => "suscripcion",
      "comercial_canal_principal" => "Inbound",
      "comercial_inversion_mes" => "2000",
      "comercial_leads_mes" => "80",
      "comercial_ventas_mes" => "25",
      "comercial_herramientas" => "HubSpot",
      "comercial_dependencia_fundador" => "Media",
      "metrica_ticket_medio" => "350",
      "metrica_cac" => "120",
      "metrica_ltv" => "4200",
      "scoring_score_promedio" => 7.5,
      "scoring_nivel_madurez_comercial" => "intermedio",
      "scoring_causa_raiz" => "Falta de proceso comercial"
    }
  end

  describe "#call" do
    subject { described_class.new(payload).call }

    it "creates a report" do
      expect { subject }.to change(Report, :count).by(1)
    end

    it "marks report as processed" do
      expect(subject.processed).to be true
    end

    it "stores scoring" do
      expect(subject.scoring).to include(:overall_score, :overall_label, :dimensions)
    end

    it "sets overall_score from scoring" do
      expect(subject.overall_score).to be_in(%w[excellent good moderate poor critical])
    end

    it "sets recommendation" do
      expect(subject.recommendation).to be_present
    end

    it "stores raw_data" do
      expect(subject.raw_data).to include("session_id" => session_id)
    end

    it "is idempotent: second call returns existing report" do
      first = subject
      second = described_class.new(payload).call
      expect(second.id).to eq(first.id)
      expect(Report.count).to eq(1)
    end

    context "missing session_id" do
      let(:payload) { { "lead_nombre" => "Juan" } }

      it "raises ArgumentError" do
        expect { subject }.to raise_error(ArgumentError, /session_id/)
      end
    end

    context "unknown session_id" do
      let(:session_id) { "unknown-session" }

      it "raises RecordNotFound" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end