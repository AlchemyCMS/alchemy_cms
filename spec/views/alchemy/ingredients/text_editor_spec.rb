# frozen_string_literal: true

require "rails_helper"

RSpec.describe "alchemy/ingredients/_text_editor" do
  let(:element) { build_stubbed(:alchemy_element, name: "all_you_can_eat_ingredients") }
  let(:element_editor) { Alchemy::ElementEditor.new(element) }
  let(:ingredient) { Alchemy::Ingredients::Text.new(role: "headline", value: "1234", element: element) }
  let(:settings) { {} }

  it_behaves_like "an alchemy ingredient editor"

  before do
    view.class.send :include, Alchemy::Admin::BaseHelper
    view.class.send :include, Alchemy::Admin::IngredientsHelper
    allow(element_editor).to receive(:ingredients) { [Alchemy::IngredientEditor.new(ingredient)] }
    allow(ingredient).to receive(:settings) { settings }
    render element_editor
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
