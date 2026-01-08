# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::LinkEditor, type: :component do
  let(:element) { build_stubbed(:alchemy_element, name: "all_you_can_eat") }
  let(:element_form) { ActionView::Helpers::FormBuilder.new(:element, element, vc_test_view_context, {}) }
  let(:ingredient_editor) { described_class.new(ingredient) }

  let(:ingredient) do
    stub_model(
      Alchemy::Ingredients::Link,
      element: element,
      role: "link"
    )
  end

  subject do
    render_inline ingredient_editor
    page
  end

  before do
    vc_test_view_context.class.include Alchemy::Admin::BaseHelper
  end

  it_behaves_like "an alchemy ingredient editor"

  it "renders a readonly text input field" do
    is_expected.to have_selector('input[type="text"][readonly]')
  end

  it "renders link buttons" do
    is_expected.to have_selector("input[type='hidden'][name='#{ingredient_editor.form_field_name(:link_title)}']")
    is_expected.to have_selector("input[type='hidden'][name='#{ingredient_editor.form_field_name(:link_class_name)}']")
    is_expected.to have_selector("input[type='hidden'][name='#{ingredient_editor.form_field_name(:link_target)}']")
  end
end
