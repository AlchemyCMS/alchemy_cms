# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::Boolean do
  it_behaves_like "an alchemy ingredient"

  let(:element) { build(:alchemy_element) }

  let(:boolean_ingredient) do
    described_class.new(
      element: element,
      type: described_class.name,
      role: "has_padding",
      value: "1"
    )
  end

  describe "value" do
    subject { boolean_ingredient.value }

    it "returns a boolean" do
      is_expected.to eq(true)
    end

    context "without value" do
      let(:boolean_ingredient) do
        described_class.new(
          element: element,
          type: described_class.name,
          role: "has_padding"
        )
      end

      it { is_expected.to be_nil }
    end

    context "with no default in definition and no value set" do
      let(:boolean_ingredient) do
        described_class.new(
          element: element,
          type: described_class.name,
          role: "has_padding"
        )
      end

      before do
        definition = Alchemy::IngredientDefinition.new(
          role: "has_padding",
          type: "Boolean"
        )
        allow(boolean_ingredient).to receive(:definition).and_return(definition)
      end

      it "returns nil" do
        is_expected.to be_nil
      end
    end

    context "with default: true in definition and no value set" do
      let(:boolean_ingredient) do
        described_class.new(
          element: element,
          type: described_class.name,
          role: "has_padding"
        )
      end

      before do
        definition = Alchemy::IngredientDefinition.new(
          role: "has_padding",
          type: "Boolean",
          default: true
        )
        allow(boolean_ingredient).to receive(:definition).and_return(definition)
      end

      it "returns true" do
        is_expected.to eq(true)
      end
    end

    context "with default: false in definition and no value set" do
      let(:boolean_ingredient) do
        described_class.new(
          element: element,
          type: described_class.name,
          role: "has_padding"
        )
      end

      before do
        definition = Alchemy::IngredientDefinition.new(
          role: "has_padding",
          type: "Boolean",
          default: false
        )
        allow(boolean_ingredient).to receive(:definition).and_return(definition)
      end

      it "returns false" do
        is_expected.to eq(false)
      end
    end

    context "with default: true in definition but explicit false value" do
      let(:boolean_ingredient) do
        described_class.new(
          element: element,
          type: described_class.name,
          role: "has_padding",
          value: false
        )
      end

      before do
        definition = Alchemy::IngredientDefinition.new(
          role: "has_padding",
          type: "Boolean",
          default: true
        )
        allow(boolean_ingredient).to receive(:definition).and_return(definition)
      end

      it "returns false (explicit value overrides default)" do
        is_expected.to eq(false)
      end
    end

    context "with default: false in definition but explicit true value" do
      let(:boolean_ingredient) do
        described_class.new(
          element: element,
          type: described_class.name,
          role: "has_padding",
          value: true
        )
      end

      before do
        definition = Alchemy::IngredientDefinition.new(
          role: "has_padding",
          type: "Boolean",
          default: false
        )
        allow(boolean_ingredient).to receive(:definition).and_return(definition)
      end

      it "returns true (explicit value overrides default)" do
        is_expected.to eq(true)
      end
    end
  end

  describe "preview_text" do
    subject { boolean_ingredient.preview_text }

    it "returns localized value" do
      is_expected.to eq("True")
    end

    context "without value" do
      let(:boolean_ingredient) do
        described_class.new(
          element: element,
          type: described_class.name,
          role: "has_padding"
        )
      end

      it { is_expected.to be_nil }
    end
  end
end
