# frozen_string_literal: true

require "rails_helper"

describe Alchemy::Ingredients::NumberView, type: :component do
  let(:ingredient) { Alchemy::Ingredients::Number.new(value: "1.3") }

  it "renders the number" do
    render_inline described_class.new(ingredient)
    expect(page).to have_content("1.3")
  end

  context "with unit option passed" do
    it "renders number with unit" do
      render_inline described_class.new(ingredient, unit: :cm)
      expect(page).to have_content("1.3 cm")
    end
  end

  context "with unit setting given" do
    let(:element) { build(:alchemy_element, name: "all_you_can_eat") }

    let(:ingredient) do
      Alchemy::Ingredients::Number.new(element:, role: "number", value: "1.3")
    end

    it "renders number with unit" do
      render_inline described_class.new(ingredient)
      expect(page).to have_content("1.3 cm")
    end

    context "with units option passed" do
      it "renders number with unit form options" do
        render_inline described_class.new(ingredient, units: {unit: :km})
        expect(page).to have_content("1.3 km")
      end
    end
  end
end
