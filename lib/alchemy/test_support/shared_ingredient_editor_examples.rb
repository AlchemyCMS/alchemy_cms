# frozen_string_literal: true

RSpec.shared_examples_for "an alchemy ingredient editor" do
  let(:ingredient_editor) { described_class.new(ingredient) }

  before do
    vc_test_view_context.class.include Alchemy::Admin::BaseHelper
    allow(vc_test_view_context).to receive(:can?).and_return(true)
  end

  subject do
    render_inline(ingredient_editor)
    page
  end

  it "renders a ingredient editor", :aggregate_failures do
    is_expected.to have_css(".ingredient-editor.#{ingredient_editor.partial_name}")
    is_expected.to have_css("[data-ingredient-role]")
    is_expected.to have_css("##{ingredient.class.model_name.param_key}_#{ingredient.id}")
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

  it "provides an ingredient id field for nested attributes" do
    counter = ingredient_editor.send(:form_field_counter)
    is_expected.to have_css(
      "input[type='hidden'][name='element[ingredients_attributes][#{counter}][id]'][value='#{ingredient.id}']",
      visible: :hidden
    )
  end
end
