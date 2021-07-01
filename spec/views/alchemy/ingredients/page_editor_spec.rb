# frozen_string_literal: true

require "rails_helper"

RSpec.describe "alchemy/ingredients/_page_editor" do
  let(:element) { build_stubbed(:alchemy_element, name: "all_you_can_eat_ingredients") }
  let(:element_editor) { Alchemy::ElementEditor.new(element) }
  let(:ingredient) { Alchemy::Ingredients::Page.new(element: element, role: "page") }

  before do
    allow(element_editor).to receive(:ingredients) { [Alchemy::IngredientEditor.new(ingredient)] }
    view.class.send(:include, Alchemy::Admin::IngredientsHelper)
  end

  subject do
    render element_editor
    rendered
  end

  it_behaves_like "an alchemy ingredient editor"

  it "renders a page input" do
    is_expected.to have_css("input.alchemy_selectbox.full_width")
  end

  context "with a page related to ingredient" do
    let(:page) { Alchemy::Page.new(id: 1) }
    let(:ingredient) { Alchemy::Ingredients::Page.new(page: page, element: element, role: "role") }

    it "sets page id as value" do
      is_expected.to have_css('input.alchemy_selectbox[value="1"]')
    end
  end
end
