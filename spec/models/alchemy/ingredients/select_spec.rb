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
      value: "A very nice bright color for the button",
    )
  end

  describe "preview_text" do
    subject { select_ingredient.preview_text }

    it "returns first 30 characters of value" do
      is_expected.to eq("A very nice bright color for t")
    end
  end
end
