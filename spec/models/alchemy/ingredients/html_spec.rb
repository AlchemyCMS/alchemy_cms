# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::Html do
  it_behaves_like "an alchemy ingredient"

  let(:element) { build(:alchemy_element) }

  let(:html_ingredient) do
    described_class.new(
      element: element,
      type: described_class.name,
      role: "tracking_code",
      value: '<script type="text/javascript"> alert("Booh!") </script>',
    )
  end

  describe "preview_text" do
    subject { html_ingredient.preview_text }

    it "return first 30 escaped characters from value" do
      is_expected.to eq("&lt;script type=&quot;text/jav")
    end

    context "without value" do
      let(:html_ingredient) do
        described_class.new(
          element: element,
          type: described_class.name,
          role: "tracking_code",
        )
      end

      it { is_expected.to eq "" }
    end
  end
end
