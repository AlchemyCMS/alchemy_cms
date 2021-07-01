# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::Boolean do
  it_behaves_like "an alchemy ingredient"

  let(:element) { build(:alchemy_element) }

  let(:boolean_ingredient) do
    described_class.new(
      element: element,
      type: described_class.name,
      role: "has_padding",
      value: "1",
    )
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
