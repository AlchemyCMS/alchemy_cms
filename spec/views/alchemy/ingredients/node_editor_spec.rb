# frozen_string_literal: true

require "rails_helper"

RSpec.describe "alchemy/ingredients/_node_editor" do
  let(:element) { build(:alchemy_element) }
  let(:ingredient) { Alchemy::Ingredients::Node.new(element: element, role: "node") }

  before do
    view.class.send(:include, Alchemy::Admin::IngredientsHelper)
  end

  subject do
    render "alchemy/ingredients/node_editor",
      node_editor: Alchemy::IngredientEditor.new(ingredient),
      node_editor_counter: 0
    rendered
  end

  it "renders a node select" do
    is_expected.to have_css("input.alchemy_selectbox.full_width")
  end

  context "with a node related to ingredient" do
    let(:node) { Alchemy::Node.new(id: 1) }
    let(:ingredient) { Alchemy::Ingredients::Node.new(node: node, element: element, role: "role") }

    it "sets node id as value" do
      is_expected.to have_css('input.alchemy_selectbox[value="1"]')
    end
  end
end
