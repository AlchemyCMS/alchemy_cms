# frozen_string_literal: true

require "rails_helper"

RSpec.describe "alchemy/ingredients/_headline_editor" do
  let(:element) { build(:alchemy_element) }

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
    render partial: "alchemy/ingredients/headline_editor", locals: {
      headline_editor: headline_editor,
      headline_editor_counter: 0,
    }
    rendered
  end

  before do
    view.class.send(:include, Alchemy::Admin::IngredientsHelper)
    allow(ingredient).to receive(:settings) { settings }
  end

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
