require "rails_helper"

RSpec.describe Chatbot::Interpreter do
  subject(:result) { described_class.new(text, language: language).call }

  let(:language) { "es" }

  describe "#call" do
    context "with empty text" do
      let(:text) { "" }

      it "returns empty intent with needs_clarification" do
        expect(result.intent).to eq(:empty)
        expect(result.confidence).to eq(0.0)
        expect(result.needs_clarification).to be true
      end
    end

    context "with scoring intent" do
      let(:text) { "Quiero hacer un diagnostico de mi negocio" }

      it "detects :scoring intent" do
        expect(result.intent).to eq(:scoring)
        expect(result.confidence).to be >= 0.5
      end
    end

    context "with journey intent" do
      let(:text) { "Necesito diseñar mi customer journey" }

      it "detects :journey intent" do
        expect(result.intent).to eq(:journey)
      end
    end

    context "with cac intent" do
      let(:text) { "Cual es el costo de adquisicion de cliente" }

      it "detects :cac intent" do
        expect(result.intent).to eq(:cac)
      end
    end

    context "with pricing intent" do
      let(:text) { "Cuanto deberia cobrar por mi servicio" }

      it "detects :pricing intent" do
        expect(result.intent).to eq(:pricing)
      end
    end

    context "with help intent" do
      let(:text) { "Que puedes hacer" }

      it "detects :help intent" do
        expect(result.intent).to eq(:help)
      end
    end

    context "with industry entity" do
      let(:text) { "Tengo una empresa de software SaaS" }

      it "extracts industry" do
        expect(result.entities[:industry]).to be_present
        expect(result.entities[:industry][:category]).to eq(:tech)
      end
    end

    context "with team_size entity" do
      let(:text) { "Somos 15 personas en el equipo" }

      it "extracts team size" do
        expect(result.entities[:team_size]).to be_present
        expect(result.entities[:team_size][:value]).to eq(15)
      end
    end

    context "with unknown intent" do
      let(:text) { "xyzabcqwerty plmn" }

      it "returns unknown intent" do
        expect(result.intent).to eq(:unknown)
        expect(result.needs_clarification).to be true
      end
    end
  end

  describe "confidence calculation" do
    it "increases with matched entities" do
      with_entities = described_class.new("Tengo un SaaS con 10 empleados").call
      without_entities = described_class.new("quiero diagnostico").call
      expect(with_entities.confidence).to be >= without_entities.confidence
    end

    it "caps at 1.0" do
      long_text = "diagnostico " + "evaluar " * 20
      result = described_class.new(long_text).call
      expect(result.confidence).to be <= 1.0
    end
  end
end