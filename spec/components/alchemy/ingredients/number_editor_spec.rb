# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::NumberEditor, type: :component do
  let(:element) { build_stubbed(:alchemy_element, name: "all_you_can_eat") }
  let(:element_form) { ActionView::Helpers::FormBuilder.new(:element, element, vc_test_view_context, {}) }
  let(:ingredient_editor) { described_class.new(ingredient, element_form:) }
  let(:ingredient) { Alchemy::Ingredients::Number.new(element: element, role: "number") }
  let(:settings) { {} }

  before do
    vc_test_view_context.class.include Alchemy::Admin::BaseHelper
    allow(ingredient).to receive(:settings) { settings }
  end

  subject do
    render_inline ingredient_editor
    page
  end

  it_behaves_like "an alchemy ingredient editor"

  it "renders a number inpur" do
    is_expected.to have_css("input[type='number']")
  end

  context "with input_type setting set to range" do
    let(:settings) { {input_type: "range"} }

    it "renders a range input" do
      is_expected.to have_css("input[type='range']")
    end

    it "renders a output tag" do
      is_expected.to have_css("output")
    end
  end

  context "with unit setting" do
    let(:settings) { {unit: "€"} }

    it "renders a unit symbol" do
      is_expected.to have_css(".input-addon", text: "€")
    end
  end
end
