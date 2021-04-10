# frozen_string_literal: true

require "rails_helper"

describe "alchemy/ingredients/_html_editor" do
  let(:element) { build(:alchemy_element) }

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
    render partial: "alchemy/ingredients/html_editor", locals: {
      html_editor: html_editor,
      html_editor_counter: 0,
    }
    rendered
  end

  before do
    view.class.send(:include, Alchemy::Admin::IngredientsHelper)
  end

  it "renders a textarea" do
    is_expected.to have_selector("textarea[name='element[ingredients_attributes][0][value]']")
  end
end
