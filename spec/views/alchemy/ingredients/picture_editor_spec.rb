# frozen_string_literal: true

require "rails_helper"

RSpec.describe "alchemy/ingredients/_picture_editor" do
  let(:page) { stub_model(Alchemy::Page) }
  let(:picture) { stub_model(Alchemy::Picture) }
  let(:element) { build_stubbed(:alchemy_element, name: "all_you_can_eat") }
  let(:element_form) { ActionView::Helpers::FormBuilder.new(:element, element, view, {}) }

  let(:ingredient) do
    stub_model(
      Alchemy::Ingredients::Picture,
      caption: "This is a cute cat",
      element: element,
      picture: picture,
      role: "image"
    )
  end

  before do
    view.class.send :include, Alchemy::Admin::BaseHelper
    assign(:page, page)
  end

  it "renders the editor component" do
    expect(ingredient).to receive(:as_editor_component).and_call_original
    render partial: "alchemy/ingredients/picture_editor", locals: {
      picture_editor: ingredient,
      element_form:
    }
  end
end
