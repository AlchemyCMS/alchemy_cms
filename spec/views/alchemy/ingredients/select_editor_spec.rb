# frozen_string_literal: true

require "rails_helper"

RSpec.describe "alchemy/ingredients/_select_editor" do
  let(:element) { build_stubbed(:alchemy_element, name: "all_you_can_eat") }
  let(:element_editor) { Alchemy::ElementEditor.new(element) }
  let(:ingredient) { Alchemy::Ingredients::Select.new(role: "select", value: "blue", element: element) }

  it_behaves_like "an alchemy ingredient editor"

  before do
    view.class.send :include, Alchemy::Admin::BaseHelper
    view.class.send :include, Alchemy::Admin::IngredientsHelper
    allow(element_editor).to receive(:ingredients) { [Alchemy::IngredientEditor.new(ingredient)] }
  end

  subject do
    render element_editor
    rendered
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
      is_expected.to have_css('alchemy-message[type="warning"]')
    end
  end

  context "if select values are set" do
    it "renders a select box" do
      is_expected.to have_css("select[is=\"alchemy-select\"]")
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
