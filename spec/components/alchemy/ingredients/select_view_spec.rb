# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::SelectView, type: :component do
  let(:ingredient) { Alchemy::Ingredients::Select.new(value: "blue") }

  it "renders the ingredients value" do
    render_inline described_class.new(ingredient)
    expect(page).to have_content("blue")
  end

  context "without value" do
    let(:ingredient) { Alchemy::Ingredients::Select.new(value: "") }

    it "does not render" do
      render_inline described_class.new(ingredient)
      expect(page).to have_content("")
    end
  end

  context "with multiple selection" do
    let(:ingredient) do
      Alchemy::Ingredients::Select.new.tap do |i|
        allow(i).to receive(:settings).and_return(
          multiple: true,
          select_values: ["handhelds", "fridges", "watches"]
        )
        i.value = ["handhelds", "watches"]
      end
    end

    it "renders array values joined with comma and space" do
      render_inline described_class.new(ingredient)
      expect(page).to have_content("handhelds and watches")
    end
  end

  context "with multiple selection and single value" do
    let(:ingredient) do
      Alchemy::Ingredients::Select.new.tap do |i|
        allow(i).to receive(:settings).and_return(
          multiple: true,
          select_values: ["handhelds", "fridges", "watches"]
        )
        i.value = ["handhelds"]
      end
    end

    it "renders single value without comma" do
      render_inline described_class.new(ingredient)
      expect(page).to have_content("handhelds")
      expect(page).not_to have_content(",")
    end
  end

  context "with multiple selection and empty value" do
    let(:ingredient) do
      Alchemy::Ingredients::Select.new.tap do |i|
        allow(i).to receive(:settings).and_return(
          multiple: true,
          select_values: ["handhelds", "fridges", "watches"]
        )
        i.value = []
      end
    end

    it "does not render" do
      render_inline described_class.new(ingredient)
      expect(page).to have_content("")
    end
  end
end
