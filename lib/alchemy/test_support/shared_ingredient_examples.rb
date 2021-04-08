# frozen_string_literal: true

require "shoulda-matchers"

RSpec.shared_examples_for "an alchemy ingredient" do
  let(:element) { build(:alchemy_element) }

  subject(:ingredient) do
    described_class.new(
      element: element,
      type: described_class.name,
      role: "headline",
    )
  end

  it { is_expected.to belong_to(:element) }
  it { is_expected.to belong_to(:related_object).optional }
  it { is_expected.to validate_presence_of(:role) }
  it { is_expected.to validate_presence_of(:type) }
  it { expect(subject.data).to eq({}) }

  describe "#settings" do
    subject { ingredient.settings }

    context "without element" do
      let(:element) { nil }

      it { is_expected.to eq({}) }
    end

    context "with element" do
      it { is_expected.to eq({ linkable: true }.with_indifferent_access) }
    end
  end

  describe "#definition" do
    subject { ingredient.definition }

    context "without element" do
      let(:element) { nil }

      it { is_expected.to eq({}) }
    end

    context "with element" do
      it do
        is_expected.to eq({
          name: "headline",
          type: "EssenceText",
          settings: {
            linkable: true,
          },
        }.with_indifferent_access)
      end
    end
  end
end
