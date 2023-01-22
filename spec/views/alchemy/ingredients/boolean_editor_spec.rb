# frozen_string_literal: true

require "rails_helper"

RSpec.describe "alchemy/ingredients/_boolean_editor" do
  let(:element) { build_stubbed(:alchemy_element, name: "all_you_can_eat") }
  let(:element_editor) { Alchemy::ElementEditor.new(element) }

  let(:ingredient) do
    Alchemy::Ingredients::Boolean.new(role: "boolean", element: element)
  end

  before do
    allow(element_editor).to receive(:ingredients) { [Alchemy::IngredientEditor.new(ingredient)] }
    view.class.send :include, Alchemy::Admin::BaseHelper
    view.class.send :include, Alchemy::Admin::IngredientsHelper
  end

  subject do
    render element_editor
    rendered
  end

  it_behaves_like "an alchemy ingredient editor"

  it "renders a checkbox" do
    is_expected.to have_selector('input[type="checkbox"]')
  end

  context "with default value given in ingredient settings" do
    let(:element) do
      create(:alchemy_element, :with_ingredients, name: "all_you_can_eat")
    end

    it "checks the checkbox" do
      within ".ingredient-editor boolean" do
        is_expected.to have_selector('input[type="checkbox"][checked="checked"]')
      end
    end
  end
end
