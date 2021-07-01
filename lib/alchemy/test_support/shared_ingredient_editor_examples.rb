# frozen_string_literal: true

RSpec.shared_examples_for "an alchemy ingredient editor" do
  let(:ingredient_editor) { Alchemy::IngredientEditor.new(ingredient) }

  before do
    view.class.send :include, Alchemy::Admin::BaseHelper
    view.class.send :include, Alchemy::Admin::IngredientsHelper
    allow(element_editor).to receive(:ingredients) { [ingredient_editor] }
  end

  subject do
    render element_editor
    rendered
  end

  it "renders a ingredient editor", :aggregate_failures do
    is_expected.to have_css(".ingredient-editor.#{ingredient_editor.partial_name}")
    is_expected.to have_css("[data-ingredient-role]")
  end
end
