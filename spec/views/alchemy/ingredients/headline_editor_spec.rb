# frozen_string_literal: true

require "rails_helper"

RSpec.describe "alchemy/ingredients/_headline_editor" do
  let(:element) { build_stubbed(:alchemy_element, name: "all_you_can_eat_ingredients") }
  let(:element_editor) { Alchemy::ElementEditor.new(element) }

  let(:ingredient) do
    stub_model(
      Alchemy::Ingredients::Headline,
      element: element,
      role: "headline",
    )
  end

  let(:headline_editor) { Alchemy::IngredientEditor.new(ingredient) }
  let(:settings) { {} }

  subject do
    render element_editor
    rendered
  end

  before do
    allow(element_editor).to receive(:ingredients) { [headline_editor] }
    view.class.send(:include, Alchemy::Admin::IngredientsHelper)
    allow(ingredient).to receive(:settings) { settings }
  end

  it_behaves_like "an alchemy ingredient editor"

  it "renders a text input" do
    is_expected.to have_selector("input[type='text'][name='element[ingredients_attributes][0][value]']")
  end

  it "renders a level select" do
    is_expected.to have_selector("select[name='element[ingredients_attributes][0][level]']")
  end

  context "when only one level is given" do
    let(:settings) do
      { levels: [1] }
    end

    it "does not render a level select" do
      is_expected.to_not have_selector("select[name='element[ingredients_attributes][0][level]']")
    end
  end

  it "does not render a size select" do
    is_expected.to_not have_selector("select[name='element[ingredients_attributes][0][size]']")
  end

  context "when sizes are given" do
    let(:settings) do
      { sizes: [1, 2] }
    end

    it "renders a size select" do
      is_expected.to have_selector("select[name='element[ingredients_attributes][0][size]']")
    end
  end
end
