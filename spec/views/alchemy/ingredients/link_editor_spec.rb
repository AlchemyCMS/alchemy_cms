# frozen_string_literal: true

require "rails_helper"

RSpec.describe "alchemy/ingredients/_link_editor" do
  let(:element) { build_stubbed(:alchemy_element, name: "all_you_can_eat") }
  let(:element_editor) { Alchemy::ElementEditor.new(element) }

  let(:ingredient) do
    stub_model(
      Alchemy::Ingredients::Link,
      element: element,
      role: "link",
    )
  end

  subject do
    render element_editor
    rendered
  end

  before do
    allow(element_editor).to receive(:ingredients) { [Alchemy::IngredientEditor.new(ingredient)] }
    view.class.send(:include, Alchemy::Admin::IngredientsHelper)
  end

  it_behaves_like "an alchemy ingredient editor"

  it "renders a readonly text input field" do
    is_expected.to have_selector('input[type="text"][readonly]')
  end

  it "renders link buttons" do
    is_expected.to have_selector('input[type="hidden"][name="element[ingredients_attributes][0][link_title]"]')
    is_expected.to have_selector('input[type="hidden"][name="element[ingredients_attributes][0][link_class_name]"]')
    is_expected.to have_selector('input[type="hidden"][name="element[ingredients_attributes][0][link_target]"]')
  end
end
