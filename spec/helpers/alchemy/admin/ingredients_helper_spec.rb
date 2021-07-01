# frozen_string_literal: true

require "rails_helper"

describe Alchemy::Admin::IngredientsHelper do
  let(:element) { build_stubbed(:alchemy_element, name: "element_with_ingredients") }
  let(:ingredient) { Alchemy::Ingredients::Text.build(role: "headline", element: element) }
  let(:ingredient_editor) { Alchemy::IngredientEditor.new(ingredient) }

  describe "#ingredient_label" do
    subject { helper.ingredient_label(ingredient_editor) }

    it "has for attribute set to ingredient form field id" do
      is_expected.to have_selector('label[for="element_ingredients_attributes_0_value"]')
    end

    context "with another column given" do
      subject { helper.ingredient_label(ingredient_editor, :picture_id) }

      it "has for attribute set to ingredient form field id for that column" do
        is_expected.to have_selector('label[for="element_ingredients_attributes_0_picture_id"]')
      end
    end

    context "with a hint" do
      before do
        expect(ingredient).to receive(:definition).at_least(:once) do
          { hint: "This is a hint" }
        end
      end

      it "has hint indicator" do
        is_expected.to have_selector("label > .hint-with-icon", text: "This is a hint")
      end
    end
  end

  describe "#render_ingredient_role" do
    subject { helper.render_ingredient_role(ingredient_editor) }

    it "returns the ingredient name" do
      is_expected.to eq("Headline")
    end

    context "if ingredient is nil" do
      let(:ingredient) { nil }

      it "returns nil" do
        is_expected.to be_nil
      end
    end

    context "with missing definition" do
      let(:ingredient) do
        mock_model "Alchemy::Ingredients::Text",
          role: "intro",
          definition: {},
          name_for_label: "Intro",
          has_validations?: false,
          deprecated?: false,
          has_warnings?: true,
          warnings: Alchemy.t(:ingredient_definition_missing),
          element: element
      end

      it "renders a warning with tooltip" do
        is_expected.to have_selector(".hint-with-icon .hint-bubble")
        is_expected.to have_content Alchemy.t(:ingredient_definition_missing)
      end
    end

    context "when deprecated" do
      let(:ingredient) do
        mock_model "Alchemy::Ingredients::Text",
          role: "intro",
          definition: { name: "intro", type: "Text", deprecated: true },
          name_for_label: "Intro",
          has_validations?: false,
          deprecated?: true,
          has_warnings?: true,
          warnings: Alchemy.t(:ingredient_deprecated),
          element: element
      end

      it "renders a deprecation notice with tooltip" do
        is_expected.to have_selector(".hint-bubble", text: Alchemy.t(:ingredient_deprecated))
      end
    end

    context "with validations" do
      before { expect(ingredient).to receive(:has_validations?).and_return(true) }

      it "show a validation indicator" do
        is_expected.to have_selector(".validation_indicator")
      end
    end
  end
end
