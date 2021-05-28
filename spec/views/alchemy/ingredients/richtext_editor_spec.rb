# frozen_string_literal: true

require "rails_helper"

RSpec.describe "alchemy/ingredients/_richtext_editor" do
  let(:element) { build_stubbed(:alchemy_element, name: "all_you_can_eat_ingredients") }
  let(:element_editor) { Alchemy::ElementEditor.new(element) }
  let(:ingredient) { Alchemy::Ingredients::Richtext.new(role: "text", value: "<p>1234</p>", element: element) }
  let(:settings) { {} }

  it_behaves_like "an alchemy ingredient editor"

  before do
    view.class.send :include, Alchemy::Admin::BaseHelper
    view.class.send :include, Alchemy::Admin::IngredientsHelper
    allow(ingredient).to receive(:settings) { settings }
    allow(element_editor).to receive(:ingredients) { [Alchemy::IngredientEditor.new(ingredient)] }
    render element_editor
  end

  it "renders a text area for tinymce" do
    expect(rendered).to have_selector(".tinymce_container textarea#tinymce_#{ingredient.id}.has_tinymce")
  end
end
