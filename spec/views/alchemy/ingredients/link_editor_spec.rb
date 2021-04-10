# frozen_string_literal: true

require "rails_helper"

RSpec.describe "alchemy/ingredients/_link_editor" do
  let(:element) { build(:alchemy_element) }

  let(:ingredient) do
    stub_model(
      Alchemy::Ingredients::Link,
      element: element,
      role: "link",
    )
  end

  subject do
    render partial: "alchemy/ingredients/link_editor", locals: {
      link_editor: Alchemy::IngredientEditor.new(ingredient),
      link_editor_counter: 0,
    }
    rendered
  end

  before do
    view.class.send(:include, Alchemy::Admin::IngredientsHelper)
  end

  it "renders a disabled text input field" do
    is_expected.to have_selector('input[type="text"][disabled]')
  end

  it "renders link buttons" do
    is_expected.to have_selector('input[type="hidden"][name="element[ingredients_attributes][0][value]"]')
    is_expected.to have_selector('input[type="hidden"][name="element[ingredients_attributes][0][link_title]"]')
    is_expected.to have_selector('input[type="hidden"][name="element[ingredients_attributes][0][link_class_name]"]')
    is_expected.to have_selector('input[type="hidden"][name="element[ingredients_attributes][0][link_target]"]')
  end
end
