# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::SelectEditor, type: :component do
  let(:element) { build_stubbed(:alchemy_element, name: "all_you_can_eat") }
  let(:ingredient) { Alchemy::Ingredients::Select.new(id: 1, role: "select", value: "blue", element: element) }

  before do
    vc_test_view_context.class.include Alchemy::Admin::BaseHelper
    allow(ingredient).to receive(:definition) do
      Alchemy::IngredientDefinition.new(role: "select", type: "Select", settings: {select_values: %w[red green blue]})
    end
  end

  it_behaves_like "an alchemy ingredient editor"
end
