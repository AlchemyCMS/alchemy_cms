# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::SelectEditor, type: :component do
  let(:element) { build_stubbed(:alchemy_element, name: "all_you_can_eat") }
  let(:ingredient) { Alchemy::Ingredients::Select.new(role: "select", value: "blue", element: element) }

  before do
    vc_test_view_context.class.send :include, Alchemy::Admin::BaseHelper
  end

  subject do
    render_inline described_class.new(ingredient)
    page
  end

  context "if no select values are set" do
    before do
      expect(ingredient).to receive(:settings).at_least(:once) do
        {
          select_values: nil
        }
      end
    end

    it "renders a warning" do
      is_expected.to have_css('alchemy-message[type="warning"]', text: /No select values given/)
    end
  end

  context "if select values are set" do
    it "renders a select box" do
      is_expected.to have_css("select[is=\"alchemy-select\"]")
    end
  end

  context "without edit permission" do
    before do
      allow(vc_test_view_context).to receive(:can?).and_return(false)
    end

    it "renders a disabled select box" do
      is_expected.to have_css("select[is=\"alchemy-select\"][disabled]")
    end
  end

  context "if select values are a hash (grouped options)" do
    before do
      expect(ingredient).to receive(:settings).at_least(:once) do
        {
          select_values: {
            "Primary" => [["Red", "red"], ["Blue", "blue"]],
            "Secondary" => [["Green", "green"], ["Yellow", "yellow"]]
          }
        }
      end
    end

    it "renders a select box with grouped options" do
      is_expected.to have_css("select[is=\"alchemy-select\"]")
      is_expected.to have_css("optgroup[label=\"Primary\"]")
      is_expected.to have_css("optgroup[label=\"Secondary\"]")
    end
  end

  context "with multiple enabled" do
    before do
      expect(ingredient).to receive(:settings).at_least(:once) do
        {
          multiple: true,
          select_values: ["handhelds", "fridges", "watches"]
        }
      end
    end

    it "renders a select box with multiple attribute" do
      is_expected.to have_css("select[multiple]")
    end

    it "renders a select box with alchemy-select custom element" do
      is_expected.to have_css("select[is=\"alchemy-select\"][multiple]")
    end
  end

  context "without multiple" do
    before do
      expect(ingredient).to receive(:settings).at_least(:once) do
        {
          multiple: false,
          select_values: ["handhelds", "fridges", "watches"]
        }
      end
    end

    it "renders a select box without multiple attribute" do
      is_expected.to have_css("select[is=\"alchemy-select\"]")
      is_expected.not_to have_css("select[multiple]")
    end
  end
end
