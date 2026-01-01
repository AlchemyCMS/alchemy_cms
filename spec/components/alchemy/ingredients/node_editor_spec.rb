# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::NodeEditor, type: :component do
  let(:element) { build_stubbed(:alchemy_element, name: "all_you_can_eat") }
  let(:element_form) { ActionView::Helpers::FormBuilder.new(:element, element, vc_test_view_context, {}) }
  let(:ingredient_editor) { described_class.new(ingredient, element_form:) }
  let(:ingredient) { Alchemy::Ingredients::Node.new(id: 123, element: element, role: "node") }

  before do
    vc_test_view_context.class.include Alchemy::Admin::BaseHelper
  end

  subject do
    render_inline ingredient_editor
    page
  end

  it_behaves_like "an alchemy ingredient editor"

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
