# frozen_string_literal: true

require "rails_helper"

RSpec.describe "alchemy/ingredients/_node_editor" do
  let(:element) { build_stubbed(:alchemy_element, name: "all_you_can_eat") }
  let(:element_form) { ActionView::Helpers::FormBuilder.new(:element, element, view, {}) }
  let(:ingredient) { Alchemy::Ingredients::Node.new(element: element, role: "node") }

  before do
    view.class.send(:include, Alchemy::Admin::BaseHelper)
  end

  it "renders the editor component" do
    expect(ingredient).to receive(:as_editor_component).and_call_original
    render partial: "alchemy/ingredients/node_editor", locals: {
      node_editor: ingredient,
      element_form:
    }
  end
end
