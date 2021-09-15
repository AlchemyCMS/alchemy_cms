# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::Boolean do
  it_behaves_like "an alchemy ingredient"

  let(:element) { build(:alchemy_element, name: "all_you_can_eat_ingredients") }

  let(:boolean_ingredient) do
    described_class.new(
      element: element,
      type: described_class.name,
      role: "boolean",
      value: "1",
    )
  end

  describe "before_validation" do
    let(:ingredient) { described_class.new(role: "boolean", element: element) }

    context "on create" do
      it "sets the default value" do
        expect(ingredient.tap(&:save!).value).to eq(true)
      end
    end

    context "on update" do
      it "does not set a value" do
        ingredient.save
        ingredient.update(value: false)
        expect(ingredient.reload.value).to eq(false)
      end
    end
  end

  describe "value" do
    subject { boolean_ingredient.value }

    it "returns a boolean" do
      is_expected.to eq(true)
    end

    context "without value" do
      let(:boolean_ingredient) do
        described_class.new(
          element: element,
          type: described_class.name,
          role: "has_padding",
        )
      end

      it { is_expected.to be_nil }
    end
  end

  describe "preview_text" do
    subject { boolean_ingredient.preview_text }

    it "returns localized value" do
      is_expected.to eq("True")
    end

    context "without value" do
      let(:boolean_ingredient) do
        described_class.new(
          element: element,
          type: described_class.name,
          role: "has_padding",
        )
      end

      it { is_expected.to be_nil }
    end
  end
end
