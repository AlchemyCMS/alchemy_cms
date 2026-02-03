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
    allow(vc_test_view_context).to receive(:can?).and_return(true)
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

  context "with color options as name/value pairs" do
    let(:settings) { {colors: [%w[Red red], %w[Blue blue]]} }
    it "renders a select with color option" do
      is_expected.to have_selector("select option[value='red']", text: "Red")
      is_expected.to have_selector("select option[value='blue']", text: "Blue")
    end

    it "sets data-swatch to the value" do
      is_expected.to have_selector("select option[value='red'][data-swatch='red']")
      is_expected.to have_selector("select option[value='blue'][data-swatch='blue']")
    end

    it "does not render a custom color option" do
      is_expected.to_not have_selector("select option[value='custom_color']")
    end

    it "renders a disabled color input" do
      is_expected.to have_selector('input[type="color"][disabled]')
    end
  end

  context "with color options as simple values" do
    let(:settings) { {colors: %w[red green]} }

    it "renders a select with color options using value as name" do
      is_expected.to have_selector("select option[value='red']", text: "red")
      is_expected.to have_selector("select option[value='green']", text: "green")
    end

    it "sets data-swatch to the value" do
      is_expected.to have_selector("select option[value='red'][data-swatch='red']")
    end
  end

  context "with color options as hashes with swatch" do
    let(:settings) do
      {
        colors: [
          {name: "Teal", value: "teal", swatch: "#008080"},
          {name: "Gray", value: "gray"}
        ]
      }
    end

    it "renders a select with color options using name" do
      is_expected.to have_selector("select option[value='teal']", text: "Teal")
      is_expected.to have_selector("select option[value='gray']", text: "Gray")
    end

    it "sets data-swatch to the swatch value when provided" do
      is_expected.to have_selector("select option[value='teal'][data-swatch='#008080']")
    end

    it "falls back to value when swatch is not provided" do
      is_expected.to have_selector("select option[value='gray'][data-swatch='gray']")
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

  context "with default value setting" do
    let(:settings) { {colors: [%w[Red red], %w[Blue blue]], default: "blue"} }

    it "selects the default value when ingredient has no value" do
      is_expected.to have_selector("select option[value='blue'][selected]")
      is_expected.to_not have_selector("select option[value='red'][selected]")
    end
  end

  context "with default value and custom color setting" do
    let(:settings) { {colors: [%w[Red red], %w[Blue blue]], default: "red", custom_color: true} }

    it "selects the default value, not custom color" do
      is_expected.to have_selector("select option[value='red'][selected]")
      is_expected.to_not have_selector("select option[value='custom_color'][selected]")
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

  context "without edit permission" do
    before do
      allow(vc_test_view_context).to receive(:can?).and_return(false)
    end

    it "renders a disabled color input" do
      is_expected.to have_selector('input[type="color"][disabled]')
    end

    context "with color options" do
      let(:settings) { {colors: [%w[Red red], %w[Blue blue]]} }

      it "renders a disabled select" do
        is_expected.to have_selector("select[disabled]")
      end
    end
  end
end
