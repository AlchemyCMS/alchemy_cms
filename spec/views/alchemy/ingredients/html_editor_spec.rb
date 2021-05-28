# frozen_string_literal: true

require "rails_helper"

describe "alchemy/ingredients/_html_editor" do
  let(:element) { build_stubbed(:alchemy_element, name: "all_you_can_eat_ingredients") }
  let(:element_editor) { Alchemy::ElementEditor.new(element) }

  let(:ingredient) do
    stub_model(
      Alchemy::Ingredients::Html,
      element: element,
      role: "source",
    )
  end

  let(:html_editor) { Alchemy::IngredientEditor.new(ingredient) }
  let(:settings) { {} }

  subject do
    render element_editor
    rendered
  end

  before do
    allow(element_editor).to receive(:ingredients) { [html_editor] }
    view.class.send(:include, Alchemy::Admin::IngredientsHelper)
  end

  it_behaves_like "an alchemy ingredient editor"

  it "renders a textarea" do
    is_expected.to have_selector("textarea[name='element[ingredients_attributes][0][value]']")
  end
end
