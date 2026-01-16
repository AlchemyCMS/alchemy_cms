# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::Color do
  it_behaves_like "an alchemy ingredient"

  let(:element) { build(:alchemy_element) }

  let(:color_ingredient) do
    described_class.new(
      element: element,
      type: described_class.name,
      role: "test",
      value: "#123456"
    )
  end

  describe "value" do
    subject { color_ingredient.value }

    it "returns a color" do
      is_expected.to eq("#123456")
    end

    context "without value" do
      let(:color_ingredient) do
        described_class.new(
          element: element,
          type: described_class.name,
          role: "test"
        )
      end

      it { is_expected.to be_nil }
    end
  end

  describe "preview_text" do
    subject { color_ingredient.preview_text }

    it "returns only the value" do
      is_expected.to eq("#123456")
    end

    context "without value" do
      let(:color_ingredient) do
        described_class.new(
          element: element,
          type: described_class.name,
          role: "test"
        )
      end

      it { is_expected.to be_empty }
    end
  end
end
