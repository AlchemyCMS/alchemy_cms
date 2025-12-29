# frozen_string_literal: true

require "rails_helper"

RSpec.describe "alchemy/ingredients/_headline_editor" do
  let(:element) { build_stubbed(:alchemy_element, name: "all_you_can_eat") }
  let(:element_form) { ActionView::Helpers::FormBuilder.new(:element, element, view, {}) }

  let(:ingredient) do
    stub_model(
      Alchemy::Ingredients::Headline,
      element: element,
      role: "headline"
    )
  end

  before do
    view.class.send(:include, Alchemy::Admin::BaseHelper)
  end

  it "renders the editor component" do
    expect(ingredient).to receive(:as_editor_component).and_call_original
    render partial: "alchemy/ingredients/headline_editor", locals: {
      headline_editor: ingredient,
      element_form:
    }
  end
end
