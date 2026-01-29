# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::ColorEditor, type: :component do
  let(:element) { build_stubbed(:alchemy_element, name: "all_you_can_eat") }
  let(:settings) { {} }

  let(:ingredient) do
    Alchemy::Ingredients::Color.new(id: 123, role: "color", element: element)
  end

  before do
    allow(ingredient).to receive(:settings) { settings }
    vc_test_view_context.class.send :include, Alchemy::Admin::BaseHelper
  end

  subject do
    render_inline described_class.new(ingredient)
    page
  end

  it_behaves_like "an alchemy ingredient editor"

  it "renders an enabled color input" do
    is_expected.to have_selector('input[type="color"]:not([disabled])')
  end

  it "does not render a select" do
    is_expected.to_not have_selector("select")
  end

  context "with color options" do
    let(:settings) { {colors: [%w[Red red], %w[Blue blue]]} }
    it "renders a select with color option" do
      is_expected.to have_selector("select option[value='red']", text: "Red")
      is_expected.to have_selector("select option[value='blue']", text: "Blue")
    end

    it "does not render a custom color option" do
      is_expected.to_not have_selector("select option[value='custom_color']")
    end

    it "renders a disabled color input" do
      is_expected.to have_selector('input[type="color"][disabled]')
    end
  end

  context "with color options and custom color setting" do
    let(:settings) { {colors: [%w[Red red], %w[Blue blue]], custom_color: true} }
    it "renders a select with color option" do
      is_expected.to have_selector("select option[value='red']", text: "Red")
      is_expected.to have_selector("select option[value='blue']", text: "Blue")
    end

    it "renders a custom color option" do
      is_expected.to have_selector("select option[value='custom_color']", text: "Custom color")
    end

    it "renders an enabled color input" do
      is_expected.to have_selector('input[type="color"]:not([disabled])')
    end
  end

  context "without color options and custom color setting disabled" do
    let(:settings) { {custom_color: false} }

    it "does not render a select" do
      is_expected.to_not have_selector("select")
    end

    it "renders an enabled color input and will ignore this setting" do
      is_expected.to have_selector('input[type="color"]:not([disabled])')
    end
  end
end
