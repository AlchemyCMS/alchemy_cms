# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::BaseEditor, type: :component do
  let(:element) { build(:alchemy_element, name: "article") }

  let(:ingredient) do
    Alchemy::Ingredients::Text.new(id: 123, role: "headline", element: element)
  end

  let(:element_form) do
    ActionView::Helpers::FormBuilder.new(:element, element, vc_test_view_context, {})
  end

  let(:ingredient_editor) { described_class.new(ingredient) }

  describe "#initialize" do
    context "when ingredient is nil" do
      it "raises ArgumentError" do
        expect {
          described_class.new(nil)
        }.to raise_error(ArgumentError, "Ingredient missing!")
      end
    end
  end

  describe "#ingredient" do
    it "returns ingredient object" do
      expect(ingredient_editor.ingredient).to be(ingredient)
    end
  end

  before do
    vc_test_view_context.class.include Alchemy::Admin::BaseHelper
  end

  subject do
    render_inline(ingredient_editor)
    page
  end

  describe "css classes" do
    it "includes ingredient-editor class" do
      is_expected.to have_selector(".ingredient-editor")
    end

    it "includes ingredient partial name class" do
      is_expected.to have_selector(".#{ingredient.partial_name}")
    end

    context "when deprecated" do
      before do
        allow(ingredient).to receive(:deprecated?) { true }
      end

      it "includes deprecated" do
        is_expected.to have_selector(".deprecated")
      end
    end

    context "when linkable" do
      before do
        expect(ingredient).to receive(:settings).at_least(:once) do
          {linkable: true}
        end
      end

      it { is_expected.to have_selector(".linkable") }
    end

    context "when with anchor" do
      before do
        expect(ingredient).to receive(:settings).at_least(:once) do
          {anchor: true}
        end
      end

      it { is_expected.to have_selector(".with-anchor") }
    end
  end

  describe "data attributes" do
    it "includes ingredient id" do
      is_expected.to have_selector('[data-ingredient-id="123"]')
    end

    it "includes ingredient role" do
      is_expected.to have_selector('[data-ingredient-role="headline"]')
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

  describe "warnings" do
    context "when ingredient has no warnings" do
      it "doesn't show any warning" do
        is_expected.to_not have_selector("sl-tooltip")
      end
    end

    context "when ingredient is missing its definition" do
      before do
        allow(ingredient).to receive(:definition) do
          Alchemy::IngredientDefinition.new
        end
      end

      it "shows warning in tooltip" do
        is_expected.to have_selector("sl-tooltip[content='#{Alchemy.t(:ingredient_definition_missing)}']")
      end

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
          element: Alchemy::Element.new(id: 1, name: "article"),
          has_validations?: false,
          has_hint?: false,
          partial_name: "text",
          settings: {},
          translated_role: "Headline",
          role: "text"
        )
      end

      it "shows deprecation notice in tooltip" do
        is_expected.to have_selector('sl-tooltip[content="Deprecated"]')
      end
    end
  end

  describe "validations" do
    context "when ingredient has no validations" do
      it "does not show any validation indicator" do
        is_expected.to_not have_selector(".validation_indicator")
      end
    end

    context "when ingredient has validations" do
      let(:ingredient) do
        mock_model(
          "Alchemy::Ingredients::Text",
          definition: Alchemy::IngredientDefinition.new(
            role: "foo",
            validate: [{format: /\A[a-z]\z/}]
          ),
          element: Alchemy::Element.new(id: 1, name: "article"),
          deprecated?: false,
          has_validations?: true,
          has_hint?: false,
          partial_name: "text",
          settings: {},
          translated_role: "Headline",
          role: "text"
        )
      end

      it "does not show any validation indicator" do
        is_expected.to have_selector(".validation_indicator")
      end
    end
  end

  describe "format validation" do
    context "when ingredient has no format validation" do
      it "does not have a pattern attribute" do
        is_expected.to_not have_selector("input[pattern]")
      end
    end

    context "when ingredient has format validation with direct regex" do
      let(:ingredient) do
        mock_model(
          "Alchemy::Ingredients::Text",
          definition: Alchemy::IngredientDefinition.new(
            role: "foo",
            validate: [{format: /\A[a-z]\z/}]
          ),
          element: Alchemy::Element.new(id: 1, name: "article"),
          deprecated?: false,
          has_validations?: true,
          has_hint?: false,
          partial_name: "text",
          settings: {},
          translated_role: "Headline",
          role: "text"
        )
      end

      it "has a pattern attribute" do
        is_expected.to have_selector("input[pattern]")
      end
    end

    context "when ingredient has format validation with config key as string" do
      let(:ingredient) do
        mock_model(
          "Alchemy::Ingredients::Text",
          definition: Alchemy::IngredientDefinition.new(
            role: "email",
            validate: [{format: "email"}]
          ),
          element: Alchemy::Element.new(id: 1, name: "article"),
          deprecated?: false,
          has_validations?: true,
          has_hint?: false,
          partial_name: "text",
          settings: {},
          translated_role: "Headline",
          role: "text"
        )
      end

      it "resolves the regex from config format_matchers" do
        is_expected.to have_selector("input[pattern]")
      end

      it "resolves the regex from config format_matchers" do
        expect(ingredient_editor.send(:format_validation)).to eq(Alchemy.config.format_matchers.email)
      end
    end

    context "when ingredient has format validation with config key as symbol" do
      let(:ingredient) do
        mock_model(
          "Alchemy::Ingredients::Text",
          definition: Alchemy::IngredientDefinition.new(
            role: "url",
            validate: [{format: :url}]
          ),
          element: Alchemy::Element.new(id: 1, name: "article"),
          deprecated?: false,
          has_validations?: true,
          has_hint?: false,
          partial_name: "text",
          settings: {},
          translated_role: "Headline",
          role: "text"
        )
      end

      it "resolves the regex from config format_matchers" do
        is_expected.to have_selector("input[pattern]")
      end

      it "resolves the regex from config format_matchers" do
        expect(ingredient_editor.send(:format_validation)).to eq(Alchemy.config.format_matchers.url)
      end
    end
  end

  describe "length validations" do
    context "when ingredient has no length validations" do
      it "does not have a minlength attribute" do
        is_expected.to_not have_selector("input[minlength]")
      end

      it "does not have a maxlength attribute" do
        is_expected.to_not have_selector("input[maxlength]")
      end
    end

    context "when ingredient has minimum length validation" do
      let(:ingredient) do
        mock_model(
          "Alchemy::Ingredients::Text",
          definition: Alchemy::IngredientDefinition.new(
            role: "foo",
            validate: [{length: {minimum: 5}}]
          ),
          element: Alchemy::Element.new(id: 1, name: "article"),
          deprecated?: false,
          has_validations?: true,
          has_hint?: false,
          partial_name: "text",
          settings: {},
          translated_role: "Headline",
          role: "text"
        )
      end

      it "has a minlength attribute" do
        is_expected.to have_selector("input[minlength=5]")
      end
    end

    context "when ingredient has maximum length validation" do
      let(:ingredient) do
        mock_model(
          "Alchemy::Ingredients::Text",
          definition: Alchemy::IngredientDefinition.new(
            role: "foo",
            validate: [{length: {maximum: 5}}]
          ),
          element: Alchemy::Element.new(id: 1, name: "article"),
          deprecated?: false,
          has_validations?: true,
          has_hint?: false,
          partial_name: "text",
          settings: {},
          translated_role: "Headline",
          role: "text"
        )
      end

      it "has a maxlength attribute" do
        is_expected.to have_selector("input[maxlength=5]")
      end
    end
  end

  describe "presence validation" do
    context "when ingredient has no presence validation" do
      it "does not have a required attribute" do
        is_expected.to_not have_selector("input[required]")
      end
    end

    context "when ingredient has presence validation as string" do
      let(:ingredient) do
        mock_model(
          "Alchemy::Ingredients::Text",
          definition: Alchemy::IngredientDefinition.new(
            role: "foo",
            validate: ["presence"]
          ),
          element: Alchemy::Element.new(id: 1, name: "article"),
          deprecated?: false,
          has_validations?: true,
          has_hint?: false,
          partial_name: "text",
          settings: {},
          translated_role: "Headline",
          role: "text"
        )
      end

      it "has a required attribute" do
        is_expected.to have_selector("input[required]")
      end
    end

    context "when ingredient has presence validation as hash with symbol key" do
      let(:ingredient) do
        mock_model(
          "Alchemy::Ingredients::Text",
          definition: Alchemy::IngredientDefinition.new(
            role: "foo",
            validate: [{presence: true}]
          ),
          element: Alchemy::Element.new(id: 1, name: "article"),
          deprecated?: false,
          has_validations?: true,
          has_hint?: false,
          partial_name: "text",
          settings: {},
          translated_role: "Headline",
          role: "text"
        )
      end

      it "has a required attribute" do
        is_expected.to have_selector("input[required]")
      end
    end

    context "when ingredient has presence validation as hash with string key" do
      let(:ingredient) do
        mock_model(
          "Alchemy::Ingredients::Text",
          definition: Alchemy::IngredientDefinition.new(
            role: "foo",
            validate: [{"presence" => true}]
          ),
          element: Alchemy::Element.new(id: 1, name: "article"),
          deprecated?: false,
          has_validations?: true,
          has_hint?: false,
          partial_name: "text",
          settings: {},
          role: "foo"
        )
      end

      it "has a required attribute" do
        is_expected.to have_selector("input[required]")
      end
    end

    context "when ingredient has presence: false with symbol key" do
      let(:ingredient) do
        mock_model(
          "Alchemy::Ingredients::Text",
          definition: Alchemy::IngredientDefinition.new(
            role: "foo",
            validate: [{presence: false}]
          ),
          element: Alchemy::Element.new(id: 1, name: "article"),
          deprecated?: false,
          has_validations?: true,
          has_hint?: false,
          partial_name: "text",
          settings: {},
          role: "text"
        )
      end

      it "has no required attribute" do
        is_expected.to have_selector("input:not([required])")
      end
    end

    context "when ingredient has presence: false with string key" do
      let(:ingredient) do
        mock_model(
          "Alchemy::Ingredients::Text",
          definition: Alchemy::IngredientDefinition.new(
            role: "foo",
            validate: [{"presence" => false}]
          ),
          element: Alchemy::Element.new(id: 1, name: "article"),
          deprecated?: false,
          has_validations?: true,
          has_hint?: false,
          partial_name: "text",
          settings: {},
          role: "text"
        )
      end

      it "has no required attribute" do
        is_expected.to have_selector("input:not([required])")
      end
    end

    context "when ingredient has only format validation" do
      let(:ingredient) do
        mock_model(
          "Alchemy::Ingredients::Text",
          definition: Alchemy::IngredientDefinition.new(
            role: "foo",
            validate: [{format: "email"}]
          ),
          element: Alchemy::Element.new(id: 1, name: "article"),
          deprecated?: false,
          has_validations?: true,
          has_hint?: false,
          partial_name: "text",
          settings: {},
          role: "text"
        )
      end

      it "has no required attribute" do
        is_expected.to have_selector("input:not([required])")
      end
    end

    context "when ingredient has format and presence validation" do
      let(:ingredient) do
        mock_model(
          "Alchemy::Ingredients::Text",
          definition: Alchemy::IngredientDefinition.new(
            role: "foo",
            validate: [:presence, {format: "email"}]
          ),
          element: Alchemy::Element.new(id: 1, name: "article"),
          deprecated?: false,
          has_validations?: true,
          has_hint?: false,
          partial_name: "text",
          settings: {},
          role: "text"
        )
      end

      it "has required attribute" do
        is_expected.to have_selector("input[required]")
      end
    end

    context "when ingredient has unknown validation type" do
      let(:ingredient) do
        mock_model(
          "Alchemy::Ingredients::Text",
          definition: Alchemy::IngredientDefinition.new(
            role: "foo",
            validate: [:uniqueness]
          ),
          element: Alchemy::Element.new(id: 1, name: "article"),
          deprecated?: false,
          has_validations?: true,
          has_hint?: false,
          partial_name: "text",
          settings: {},
          role: "text"
        )
      end

      it "has no required attribute" do
        is_expected.to have_selector("input:not([required])")
      end
    end
  end

  describe "#ingredient_label" do
    it "has for attribute set to ingredient form field id" do
      is_expected.to have_selector("label[for='element_#{element.id}_ingredient_#{ingredient.id}_value']")
    end

    context "with a hint" do
      before do
        expect(ingredient).to receive(:definition).at_least(:once) do
          Alchemy::IngredientDefinition.new(hint: "This is a hint")
        end
      end

      it "has hint indicator" do
        is_expected.to have_selector("label > .like-hint-tooltip", text: "This is a hint")
      end
    end
  end
end
