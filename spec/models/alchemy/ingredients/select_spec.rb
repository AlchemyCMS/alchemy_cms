# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::Select do
  it_behaves_like "an alchemy ingredient"

  let(:element) { build(:alchemy_element) }

  let(:select_ingredient) do
    described_class.new(
      element: element,
      type: described_class.name,
      role: "color",
      value: "A very nice bright color for the button"
    )
  end

  describe "preview_text" do
    subject { select_ingredient.preview_text }

    it "returns first 30 characters of value" do
      is_expected.to eq("A very nice bright color for t")
    end
  end

  describe "multiple selection functionality" do
    let(:element_with_multiple) do
      build(:alchemy_element, name: "test_element")
    end

    let(:multiple_ingredient) do
      described_class.new(
        element: element_with_multiple,
        type: described_class.name,
        role: "devices"
      )
    end

    before do
      allow(multiple_ingredient).to receive(:settings).and_return(
        multiple: true,
        select_values: ["handhelds", "fridges", "watches"]
      )
    end

    describe "#multiple?" do
      it "returns true when multiple setting is enabled" do
        expect(multiple_ingredient.multiple?).to be(true)
      end

      it "returns false when multiple setting is not enabled" do
        expect(select_ingredient.multiple?).to be(false)
      end
    end

    describe "#value=" do
      context "with multiple enabled" do
        it "stores array" do
          multiple_ingredient.value = ["handhelds", "watches"]
          # With serialize, ActiveRecord handles JSON encoding
          expect(multiple_ingredient.value).to eq(["handhelds", "watches"])
        end

        it "handles empty array" do
          multiple_ingredient.value = []
          expect(multiple_ingredient.value).to eq([])
        end

        it "handles nil value" do
          multiple_ingredient.value = nil
          expect(multiple_ingredient.value).to eq([])
        end

        it "removes blank values" do
          multiple_ingredient.value = ["handhelds", "", "watches", nil]
          expect(multiple_ingredient.value).to eq(["handhelds", "watches"])
        end

        it "handles single string value" do
          multiple_ingredient.value = "handhelds"
          expect(multiple_ingredient.value).to eq(["handhelds"])
        end
      end

      context "without multiple" do
        it "stores value as string" do
          select_ingredient.value = "red"
          expect(select_ingredient.value).to eq("red")
        end
      end
    end

    describe "#value" do
      context "with multiple enabled" do
        it "returns array" do
          multiple_ingredient.value = ["handhelds", "watches"]
          expect(multiple_ingredient.value).to eq(["handhelds", "watches"])
        end

        it "returns empty array for nil value" do
          multiple_ingredient.value = nil
          expect(multiple_ingredient.value).to eq([])
        end

        it "returns empty array for empty array" do
          multiple_ingredient.value = []
          expect(multiple_ingredient.value).to eq([])
        end
      end

      context "without multiple" do
        it "returns string value" do
          select_ingredient.value = "red"
          expect(select_ingredient.value).to eq("red")
        end
      end
    end
  end
end
