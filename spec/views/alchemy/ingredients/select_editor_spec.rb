# frozen_string_literal: true

require "rails_helper"

RSpec.describe "alchemy/ingredients/_select_editor" do
  let(:element) { build(:alchemy_element, name: "all_you_can_eat_ingredients") }
  let(:ingredient) { Alchemy::Ingredients::Select.new(role: "select", value: "blue", element: element) }

  it_behaves_like "an alchemy ingredient editor"

  before do
    view.class.send :include, Alchemy::Admin::BaseHelper
    view.class.send :include, Alchemy::Admin::IngredientsHelper
  end

  subject do
    render "alchemy/ingredients/select_editor",
      select_editor: Alchemy::IngredientEditor.new(ingredient),
      select_editor_counter: 0
    rendered
  end

  context "if no select values are set" do
    before do
      expect(ingredient).to receive(:settings).at_least(:once) do
        {
          select_values: nil,
        }
      end
    end

    it "renders a warning" do
      is_expected.to have_css(".warning")
    end
  end

  context "if select values are set" do
    it "renders a select box" do
      is_expected.to have_css("select.alchemy_selectbox")
    end
  end
end
