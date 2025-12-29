# frozen_string_literal: true

require "rails_helper"

RSpec.describe "alchemy/ingredients/_richtext_editor" do
  let(:element) { build_stubbed(:alchemy_element, name: "all_you_can_eat") }
  let(:element_form) { ActionView::Helpers::FormBuilder.new(:element, element, view, {}) }
  let(:ingredient) { Alchemy::Ingredients::Richtext.new(role: "text", value: "<p>1234</p>", element: element) }

  before do
    view.class.send :include, Alchemy::Admin::BaseHelper
  end

  it "renders the editor component" do
    expect(ingredient).to receive(:as_editor_component).and_call_original
    render partial: "alchemy/ingredients/richtext_editor", locals: {
      richtext_editor: ingredient,
      element_form:
    }
  end
end
