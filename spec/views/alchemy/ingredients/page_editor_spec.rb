# frozen_string_literal: true

require "rails_helper"

RSpec.describe "alchemy/ingredients/_page_editor" do
  let(:element) { build(:alchemy_element) }
  let(:ingredient) { Alchemy::Ingredients::Page.new(element: element, role: "page") }

  before do
    view.class.send(:include, Alchemy::Admin::IngredientsHelper)
    puts subject
  end

  subject do
    render "alchemy/ingredients/page_editor",
      page_editor: Alchemy::IngredientEditor.new(ingredient),
      page_editor_counter: 0
    rendered
  end

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
