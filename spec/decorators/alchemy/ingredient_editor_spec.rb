# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::IngredientEditor do
  let(:element) { build(:alchemy_element, name: "element_with_ingredients") }
  let(:ingredient) { Alchemy::Ingredients::Text.build(role: "headline", element: element) }
  let(:ingredient_editor) { described_class.new(ingredient) }

  describe "#ingredient" do
    it "returns ingredient object" do
      expect(ingredient_editor.ingredient).to be(ingredient)
    end
  end

  describe "#css_classes" do
    subject { ingredient_editor.css_classes }

    it "includes ingredient_editor class" do
      is_expected.to include("ingredient-editor")
    end

    it "includes essence partial class" do
      is_expected.to include(ingredient.partial_name)
    end

    context "when deprecated" do
      before do
        expect(ingredient).to receive(:deprecated?) { true }
      end

      it "includes deprecated" do
        is_expected.to include("deprecated")
      end
    end
  end

  describe "#data_attributes" do
    it "includes ingredient_id" do
      expect(ingredient_editor.data_attributes[:ingredient_id]).to eq(ingredient.id)
    end

    it "includes ingredient_role" do
      expect(ingredient_editor.data_attributes[:ingredient_role]).to eq(ingredient.role)
    end
  end

  describe "#to_partial_path" do
    subject { ingredient_editor.to_partial_path }

    it "returns the editor partial path" do
      is_expected.to eq("alchemy/ingredients/text_editor")
    end
  end

  describe "#form_field_name" do
    it "returns a name for form fields with value as default" do
      expect(ingredient_editor.form_field_name).to eq("element[ingredients_attributes][0][value]")
    end

    context "with a value given" do
      it "returns a name for form fields for that column" do
        expect(ingredient_editor.form_field_name(:link_title)).to eq("element[ingredients_attributes][0][link_title]")
      end
    end
  end

  describe "#form_field_id" do
    it "returns a id value for form fields with ingredient as default" do
      expect(ingredient_editor.form_field_id).to eq("element_ingredients_attributes_0_value")
    end

    context "with a value given" do
      it "returns a id value for form fields for that column" do
        expect(ingredient_editor.form_field_id(:link_title)).to eq("element_ingredients_attributes_0_link_title")
      end
    end
  end

  describe "#respond_to?(:to_model)" do
    subject { ingredient_editor.respond_to?(:to_model) }

    it { is_expected.to be(false) }
  end

  describe "#has_warnings?" do
    subject { ingredient_editor.has_warnings? }

    context "when ingredient is not deprecated" do
      it { is_expected.to be(false) }
    end

    context "when ingredient is deprecated" do
      let(:ingredient) do
        mock_model("Alchemy::Ingredients::Text", definition: { deprecated: true }, deprecated?: true)
      end

      it { is_expected.to be(true) }
    end

    context "when ingredient is missing its definition" do
      let(:ingredient) do
        mock_model("Alchemy::Ingredients::Text", definition: {})
      end

      it { is_expected.to be(true) }
    end
  end

  describe "#warnings" do
    subject { ingredient_editor.warnings }

    context "when ingredient has no warnings" do
      it { is_expected.to be_nil }
    end

    context "when ingredient is missing its definition" do
      let(:ingredient) do
        mock_model("Alchemy::Ingredients::Text", definition: {})
      end

      it { is_expected.to eq Alchemy.t(:ingredient_definition_missing) }

      it "logs a warning" do
        expect(Alchemy::Logger).to receive(:warn)
        subject
      end
    end

    context "when ingredient is deprecated" do
      let(:ingredient) do
        mock_model(
          "Alchemy::Ingredients::Text",
          definition: {
            role: "foo",
            deprecated: "Deprecated",
          }, deprecated?: true,
        )
      end

      it "returns a deprecation notice" do
        is_expected.to eq("Deprecated")
      end
    end
  end

  describe "#deprecation_notice" do
    subject { ingredient_editor.deprecation_notice }

    context "when ingredient is not deprecated" do
      it { is_expected.to be_nil }
    end

    context "when ingredient is deprecated" do
      context "with String as deprecation" do
        let(:ingredient) do
          mock_model(
            "Alchemy::Ingredients::Text",
            definition: {
              role: "foo",
              deprecated: "Ingredient is deprecated",
            }, deprecated?: true,
          )
        end

        it { is_expected.to eq("Ingredient is deprecated") }
      end

      context "without custom ingredient translation" do
        let(:ingredient) do
          mock_model(
            "Alchemy::Ingredients::Text",
            definition: {
              role: "foo",
              deprecated: true,
            }, deprecated?: true,
            element: element,
          )
        end

        it do
          is_expected.to eq(
            "WARNING! This content is deprecated and will be removed soon. " \
            "Please do not use it anymore."
          )
        end
      end

      context "with custom ingredient translation" do
        let(:element) { build(:alchemy_element, name: "all_you_can_eat_ingredients") }

        let(:ingredient) do
          Alchemy::Ingredients::Html.build(
            role: "html",
            element: element,
          )
        end

        it { is_expected.to eq("Old ingredient is deprecated") }
      end
    end
  end
end
