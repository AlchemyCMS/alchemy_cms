# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::IngredientEditor, :silence_deprecations do
  let(:element) { build(:alchemy_element, name: "article") }
  let(:ingredient) { Alchemy::Ingredients::Text.new(role: "headline", element: element) }
  let(:ingredient_editor) { described_class.new(ingredient) }

  describe "#ingredient" do
    it "returns ingredient object" do
      expect(ingredient_editor.ingredient).to be(ingredient)
    end
  end

  describe "#css_classes" do
    subject { ingredient_editor.css_classes }

    it "includes ingredient-editor class" do
      is_expected.to include("ingredient-editor")
    end

    it "includes ingredient partial name class" do
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

    context "when responding to level_options" do
      context "and having any level options" do
        before do
          expect(ingredient).to receive(:level_options) do
            [["H1", 1]]
          end
        end

        it { is_expected.to include("with-level-select") }
      end
    end

    context "when responding to size_options" do
      context "and having many size options" do
        before do
          expect(ingredient).to receive(:size_options) do
            [[".h1", 1], [".h2", 2]]
          end
        end

        it { is_expected.to include("with-size-select") }
      end
    end

    context "when linkable" do
      before do
        expect(ingredient).to receive(:settings).at_least(:once) do
          {linkable: true}
        end
      end

      it { is_expected.to include("linkable") }
    end

    context "when with anchor" do
      before do
        expect(ingredient).to receive(:settings).at_least(:once) do
          {anchor: true}
        end
      end

      it { is_expected.to include("with-anchor") }
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
      expect(ingredient_editor.form_field_name).to eq("element[ingredients_attributes][1][value]")
    end

    context "with a value given" do
      it "returns a name for form fields for that column" do
        expect(ingredient_editor.form_field_name(:link_title)).to eq("element[ingredients_attributes][1][link_title]")
      end
    end
  end

  describe "#form_field_id" do
    it "returns a id value for form fields with ingredient as default" do
      expect(ingredient_editor.form_field_id).to eq("element_#{element.id}_ingredient_#{ingredient.id}_value")
    end

    context "with a value given" do
      it "returns a id value for form fields for that column" do
        expect(ingredient_editor.form_field_id(:link_title)).to eq("element_#{element.id}_ingredient_#{ingredient.id}_link_title")
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
        mock_model(
          "Alchemy::Ingredients::Text",
          definition: Alchemy::IngredientDefinition.new(deprecated: true),
          deprecated?: true
        )
      end

      it { is_expected.to be(true) }
    end

    context "when ingredient is missing its definition" do
      let(:ingredient) do
        mock_model(
          "Alchemy::Ingredients::Text",
          definition: Alchemy::IngredientDefinition.new
        )
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
        mock_model(
          "Alchemy::Ingredients::Text",
          definition: Alchemy::IngredientDefinition.new,
          element: nil
        )
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
          definition: Alchemy::IngredientDefinition.new(
            role: "foo",
            deprecated: "Deprecated"
          ),
          deprecated?: true,
          element: nil
        )
      end

      it "returns a deprecation notice" do
        is_expected.to eq("Deprecated")
      end
    end
  end

  describe "#validations" do
    subject { ingredient_editor.validations }

    context "when ingredient has no validations" do
      it { is_expected.to eq([]) }
    end

    context "when ingredient has validations" do
      let(:ingredient) do
        mock_model(
          "Alchemy::Ingredients::Text",
          definition: Alchemy::IngredientDefinition.new(
            role: "foo",
            validate: [{format: /\A[a-z]+\z/}]
          )
        )
      end

      it { is_expected.to include({format: /\A[a-z]+\z/}) }
    end
  end

  describe "#format_validation" do
    subject { ingredient_editor.format_validation }

    context "when ingredient has no format validation" do
      it { is_expected.to be_nil }
    end

    context "when ingredient has format validation with direct regex" do
      let(:ingredient) do
        mock_model(
          "Alchemy::Ingredients::Text",
          definition: Alchemy::IngredientDefinition.new(
            role: "foo",
            validate: [{format: /\A[a-z]+\z/}]
          )
        )
      end

      it { is_expected.to eq(/\A[a-z]+\z/) }
    end

    context "when ingredient has format validation with config key as string" do
      let(:ingredient) do
        mock_model(
          "Alchemy::Ingredients::Text",
          definition: Alchemy::IngredientDefinition.new(
            role: "email",
            validate: [{format: "email"}]
          )
        )
      end

      it "resolves the regex from config format_matchers" do
        expect(subject).to eq(Alchemy.config.format_matchers.email)
      end
    end

    context "when ingredient has format validation with config key as symbol" do
      let(:ingredient) do
        mock_model(
          "Alchemy::Ingredients::Text",
          definition: Alchemy::IngredientDefinition.new(
            role: "url",
            validate: [{format: :url}]
          )
        )
      end

      it "resolves the regex from config format_matchers" do
        expect(subject).to eq(Alchemy.config.format_matchers.url)
      end
    end
  end

  describe "#length_validation" do
    subject { ingredient_editor.length_validation }

    context "when ingredient has no length validation" do
      it { is_expected.to be_nil }
    end

    context "when ingredient has length validation" do
      let(:ingredient) do
        mock_model(
          "Alchemy::Ingredients::Text",
          definition: Alchemy::IngredientDefinition.new(
            role: "foo",
            validate: [{length: {minimum: 5}}]
          )
        )
      end

      it { is_expected.to eq({minimum: 5}.with_indifferent_access) }
    end
  end

  describe "#presence_validation?" do
    subject { ingredient_editor.presence_validation? }

    context "when ingredient has no presence validation" do
      it { is_expected.to be(false) }
    end

    context "when ingredient has presence validation as symbol" do
      let(:ingredient) do
        mock_model(
          "Alchemy::Ingredients::Text",
          definition: Alchemy::IngredientDefinition.new(
            role: "foo",
            validate: [:presence]
          )
        )
      end

      it { is_expected.to be(true) }
    end

    context "when ingredient has presence validation as string" do
      let(:ingredient) do
        mock_model(
          "Alchemy::Ingredients::Text",
          definition: Alchemy::IngredientDefinition.new(
            role: "foo",
            validate: ["presence"]
          )
        )
      end

      it { is_expected.to be(true) }
    end

    context "when ingredient has presence validation as hash with symbol key" do
      let(:ingredient) do
        mock_model(
          "Alchemy::Ingredients::Text",
          definition: Alchemy::IngredientDefinition.new(
            role: "foo",
            validate: [{presence: true}]
          )
        )
      end

      it { is_expected.to be(true) }
    end

    context "when ingredient has presence validation as hash with string key" do
      let(:ingredient) do
        mock_model(
          "Alchemy::Ingredients::Text",
          definition: Alchemy::IngredientDefinition.new(
            role: "foo",
            validate: [{"presence" => true}]
          )
        )
      end

      it { is_expected.to be(true) }
    end

    context "when ingredient has presence: false with symbol key" do
      let(:ingredient) do
        mock_model(
          "Alchemy::Ingredients::Text",
          definition: Alchemy::IngredientDefinition.new(
            role: "foo",
            validate: [{presence: false}]
          )
        )
      end

      it { is_expected.to be(false) }
    end

    context "when ingredient has presence: false with string key" do
      let(:ingredient) do
        mock_model(
          "Alchemy::Ingredients::Text",
          definition: Alchemy::IngredientDefinition.new(
            role: "foo",
            validate: [{"presence" => false}]
          )
        )
      end

      it { is_expected.to be(false) }
    end

    context "when ingredient has only format validation" do
      let(:ingredient) do
        mock_model(
          "Alchemy::Ingredients::Text",
          definition: Alchemy::IngredientDefinition.new(
            role: "foo",
            validate: [{format: "email"}]
          )
        )
      end

      it { is_expected.to be(false) }
    end

    context "when ingredient has format and presence validation" do
      let(:ingredient) do
        mock_model(
          "Alchemy::Ingredients::Text",
          definition: Alchemy::IngredientDefinition.new(
            role: "foo",
            validate: [:presence, {format: "email"}]
          )
        )
      end

      it { is_expected.to be(true) }
    end
  end
end
