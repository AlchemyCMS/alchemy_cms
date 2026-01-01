# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::DatetimeEditor, type: :component do
  let(:element) { build_stubbed(:alchemy_element, name: "all_you_can_eat") }

  let(:element_form) do
    ActionView::Helpers::FormBuilder.new(:element, element, vc_test_view_context, {})
  end

  let(:ingredient_editor) { described_class.new(ingredient, element_form:) }
  let(:ingredient) { Alchemy::Ingredients::Datetime.new(id: 1234, role: "datetime", element: element) }

  before do
    vc_test_view_context.class.send(:include, Alchemy::Admin::BaseHelper)
  end

  it_behaves_like "an alchemy ingredient editor"

  it "renders a datepicker" do
    render_inline ingredient_editor
    expect(page).to have_css('alchemy-datepicker[input-type="datetime"] input[type="text"].datetime')
  end
end
