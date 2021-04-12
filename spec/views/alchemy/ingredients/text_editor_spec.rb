# frozen_string_literal: true

require "rails_helper"

RSpec.describe "alchemy/ingredients/_text_editor" do
  let(:element) { build(:alchemy_element, name: "element_with_ingredients") }
  let(:ingredient) { Alchemy::Ingredients::Text.new(role: "headline", value: "1234", element: element) }
  let(:settings) { {} }

  it_behaves_like "an alchemy ingredient editor"

  before do
    view.class.send :include, Alchemy::Admin::BaseHelper
    view.class.send :include, Alchemy::Admin::IngredientsHelper
    allow(ingredient).to receive(:settings) { settings }
    render partial: "alchemy/ingredients/text_editor", locals: {
      text_editor: Alchemy::IngredientEditor.new(ingredient),
      text_editor_counter: 0,
    }
  end

  context "with no input type set" do
    it "renders an input field of type number" do
      expect(rendered).to have_selector('input[type="text"]')
    end
  end

  context "with a different input type set" do
    let(:settings) do
      {
        input_type: "number",
      }
    end

    it "renders an input field of type number" do
      expect(rendered).to have_selector('input[type="number"]')
    end
  end

  context "with settings linkable set to true" do
    let(:settings) do
      {
        linkable: true,
      }
    end

    it "renders link buttons" do
      expect(rendered).to have_selector('input[type="hidden"][name="element[ingredients_attributes][0][link]"]')
      expect(rendered).to have_selector('input[type="hidden"][name="element[ingredients_attributes][0][link_title]"]')
      expect(rendered).to have_selector('input[type="hidden"][name="element[ingredients_attributes][0][link_class_name]"]')
      expect(rendered).to have_selector('input[type="hidden"][name="element[ingredients_attributes][0][link_target]"]')
    end
  end
end
