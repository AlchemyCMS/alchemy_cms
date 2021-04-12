# frozen_string_literal: true

RSpec.shared_examples_for "an alchemy ingredient editor" do
  let(:ingredient_editor) { Alchemy::IngredientEditor.new(ingredient) }

  before do
    view.class.send :include, Alchemy::Admin::BaseHelper
    view.class.send :include, Alchemy::Admin::IngredientsHelper
  end

  before do
    render partial: ingredient_editor.to_partial_path, locals: {
      "#{ingredient_editor.partial_name}_editor".to_sym => ingredient_editor,
      "#{ingredient_editor.partial_name}_editor_counter".to_sym => 0,
    }
  end

  it "renders a ingredient editor", :aggregate_failures do
    expect(rendered).to have_css(".ingredient-editor.#{ingredient_editor.partial_name}")
    expect(rendered).to have_css("[data-ingredient-role]")
  end
end
