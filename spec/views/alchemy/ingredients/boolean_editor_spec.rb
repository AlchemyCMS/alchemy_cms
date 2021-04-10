# frozen_string_literal: true

require "rails_helper"

RSpec.describe "alchemy/ingredients/_boolean_editor" do
  let(:element) { build(:alchemy_element, name: "all_you_can_eat_ingredients") }

  let(:ingredient) do
    Alchemy::Ingredients::Boolean.build(role: "boolean", type: "Boolean", element: element)
  end

  before do
    view.class.send :include, Alchemy::Admin::BaseHelper
    view.class.send :include, Alchemy::Admin::IngredientsHelper
  end

  subject do
    render partial: "alchemy/ingredients/boolean_editor", locals: {
      boolean_editor: Alchemy::IngredientEditor.new(ingredient),
      boolean_editor_counter: 0,
    }
    rendered
  end

  it "renders a checkbox" do
    is_expected.to have_selector('input[type="checkbox"]')
  end

  context "with default value given in ingredient settings" do
    before do
      expect(element).to receive(:ingredient_definition_for) { ingredient_definition }
      allow_any_instance_of(Alchemy::Ingredients::Boolean).to receive(:definition) { ingredient_definition }
    end

    let(:ingredient_definition) do
      {
        role: "boolean",
        type: "Boolean",
        default: true,
      }.with_indifferent_access
    end

    it "checks the checkbox" do
      is_expected.to have_selector('input[type="checkbox"][checked="checked"]')
    end
  end
end
