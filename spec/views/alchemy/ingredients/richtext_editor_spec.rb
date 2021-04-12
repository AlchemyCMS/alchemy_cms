# frozen_string_literal: true

require "rails_helper"

RSpec.describe "alchemy/ingredients/_richtext_editor" do
  let(:element) { build(:alchemy_element, name: "element_with_ingredients") }
  let(:ingredient) { Alchemy::Ingredients::Richtext.new(role: "text", value: "<p>1234</p>", element: element) }
  let(:settings) { {} }

  it_behaves_like "an alchemy ingredient editor"

  before do
    view.class.send :include, Alchemy::Admin::BaseHelper
    view.class.send :include, Alchemy::Admin::IngredientsHelper
    allow(ingredient).to receive(:settings) { settings }
    render partial: "alchemy/ingredients/richtext_editor", locals: {
      richtext_editor: Alchemy::IngredientEditor.new(ingredient),
      richtext_editor_counter: 0,
    }
  end

  it "renders a text area for tinymce" do
    expect(rendered).to have_selector(".tinymce_container textarea#tinymce_#{ingredient.id}.has_tinymce")
  end
end
