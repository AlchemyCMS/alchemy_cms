# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredient do
  let(:element) do
    build(:alchemy_element, name: "element_with_ingredients", autogenerate_ingredients: false)
  end

  describe ".build" do
    subject { described_class.build(attributes) }

    context "without element" do
      let(:attributes) { {} }

      it { expect { subject }.to raise_error(ArgumentError) }
    end

    context "with element" do
      context "without role given" do
        let(:attributes) { { element: element } }

        it { expect { subject }.to raise_error(ArgumentError) }
      end

      context "with role given" do
        let(:attributes) { { element: element, role: "headline" } }

        it { is_expected.to be_an(Alchemy::Ingredients::Text) }
      end

      context "with default defined" do
        let(:attributes) { { element: element, role: "headline" } }

        it "sets default value" do
          expect(subject.value).to eq("Hello World")
        end
      end

      context "with undefined role given" do
        let(:attributes) { { element: element, role: "foo" } }

        it { expect { subject }.to raise_error(Alchemy::Ingredient::DefinitionError) }
      end
    end
  end

  describe ".create" do
    subject { described_class.create(attributes) }

    let(:attributes) { { element: element, role: "headline" } }

    it { expect { subject }.to change(Alchemy::Ingredients::Text, :count).by(1) }

    it "returns self" do
      is_expected.to be_an(Alchemy::Ingredients::Text)
    end
  end

  describe "#settings" do
    let(:ingredient) { Alchemy::Ingredients::Text.build(role: "headline", element: element) }

    it "returns the settings hash from definition" do
      expect(ingredient.settings).to eq({ "linkable" => true })
    end

    context "if settings are not defined" do
      let(:ingredient) { Alchemy::Ingredients::Text.build(role: "text", element: element) }

      it "returns empty hash" do
        expect(ingredient.settings).to eq({})
      end
    end
  end

  describe "#settings_value" do
    let(:ingredient) { Alchemy::Ingredients::Text.build(role: "headline", element: element) }
    let(:key) { :linkable }
    let(:options) { {} }

    subject { ingredient.settings_value(key, options) }

    context "with ingredient having settings" do
      context "and empty options" do
        it "returns the value for key from ingredient settings" do
          expect(subject).to eq(true)
        end
      end

      context "and nil options" do
        let(:options) { nil }

        it "returns the value for key from ingredient settings" do
          expect(subject).to eq(true)
        end
      end

      context "but same key present in options" do
        let(:options) { { linkable: false } }

        it "returns the value for key from options" do
          expect(subject).to eq(false)
        end
      end

      context "and key passed as string" do
        let(:key) { "linkable" }

        it "returns the value" do
          expect(subject).to eq(true)
        end
      end
    end

    context "with ingredient having no settings" do
      let(:ingredient) { Alchemy::Ingredients::Richtext.build(role: "text", element: element) }

      context "and empty options" do
        let(:options) { {} }

        it { expect(subject).to eq(nil) }
      end

      context "but key present in options" do
        let(:options) { { linkable: false } }

        it "returns the value for key from options" do
          expect(subject).to eq(false)
        end
      end
    end
  end

  describe "#partial_name" do
    let(:ingredient) { Alchemy::Ingredients::Richtext.build(role: "text", element: element) }

    subject { ingredient.partial_name }

    it "returns the demodulized underscored class name" do
      is_expected.to eq "richtext"
    end
  end

  describe "#to_partial_path" do
    let(:ingredient) { Alchemy::Ingredients::Richtext.build(role: "text", element: element) }

    subject { ingredient.to_partial_path }

    it "returns the path to the view partial" do
      is_expected.to eq "alchemy/ingredients/richtext_view"
    end
  end
end
