# frozen_string_literal: true

RSpec.shared_examples_for "an alchemy ingredient editor" do
  let(:element_form) do
    ActionView::Helpers::FormBuilder.new(:element, element, vc_test_view_context, {})
  end

  let(:ingredient_editor) { described_class.new(ingredient, element_form:) }

  before do
    vc_test_view_context.class.include Alchemy::Admin::BaseHelper
  end

  subject do
    render_inline(ingredient_editor)
    page
  end

  it "renders a ingredient editor", :aggregate_failures do
    is_expected.to have_css(".ingredient-editor.#{ingredient_editor.partial_name}")
    is_expected.to have_css("[data-ingredient-role]")
  end

  it "provides a label" do
    is_expected.to have_css("label[for]", text: Alchemy.t(
      ingredient_editor.role,
      scope: "ingredient_roles.#{element.name}",
      default: Alchemy.t("ingredient_roles.#{ingredient_editor.role}", default: ingredient_editor.role.humanize)
    ))
  end

  it "provides a ingredient input field" do
    is_expected.to have_css("input[name]")
  end
end
