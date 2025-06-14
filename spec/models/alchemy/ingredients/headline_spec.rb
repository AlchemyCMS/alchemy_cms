# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::Headline do
  subject(:ingredient) do
    described_class.new(
      value: value,
      dom_id: "se-headline",
      level: 2,
      size: 3
    )
  end

  let(:value) { "A headline" }

  it_behaves_like "an alchemy ingredient"
  it_behaves_like "having dom ids"

  describe "#dom_id" do
    subject { ingredient.dom_id }

    it { is_expected.to eq("se-headline") }
  end

  describe "#level_options" do
    subject { ingredient.level_options }

    it { is_expected.to eq([["H1", 1], ["H2", 2], ["H3", 3], ["H4", 4], ["H5", 5], ["H6", 6]]) }

    context "when restricted through the ingredient settings" do
      before do
        expect(ingredient).to receive(:settings).and_return(levels: [2, 3])
      end

      it { is_expected.to eq([["H2", 2], ["H3", 3]]) }
    end
  end

  describe "#size_options" do
    subject { ingredient.size_options }

    it { is_expected.to eq([]) }

    context "when enabled through the ingredient settings" do
      before do
        expect(ingredient).to receive(:settings).and_return(sizes: [3, 4])
      end

      it { is_expected.to eq([[".h3", 3], [".h4", 4]]) }
    end

    context "when two dimensional array" do
      before do
        expect(ingredient).to receive(:settings) do
          {
            sizes: [["XL", "text-xl"], ["L", "text-lg"]]
          }
        end
      end

      it { is_expected.to eq([["XL", "text-xl"], ["L", "text-lg"]]) }
    end
  end

  describe "creating from a settings" do
    let(:element) { create(:alchemy_element) }

    before do
      expect(element).to receive(:ingredient_definition_for).at_least(:once) do
        Alchemy::IngredientDefinition.new(
          role: "headline",
          type: "Headline",
          settings: {
            sizes: [3],
            levels: [2, 3]
          }
        )
      end
    end

    it "should have the size and level fields filled with correct defaults" do
      ingredient = described_class.create(element: element, role: "headline")
      expect(ingredient.size).to eq(3)
      expect(ingredient.level).to eq(2)
    end
  end
end
