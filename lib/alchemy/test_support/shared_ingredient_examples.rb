# frozen_string_literal: true

require "shoulda-matchers"

RSpec.shared_examples_for "an alchemy ingredient" do
  let(:element) { build(:alchemy_element, name: "element_with_ingredients") }

  subject(:ingredient) do
    described_class.new(
      element: element,
      role: "headline",
    )
  end

  it { is_expected.to belong_to(:element).touch(true).class_name("Alchemy::Element") }
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
          role: "headline",
          type: "Text",
          default: "Hello World",
          settings: {
            linkable: true,
          },
        }.with_indifferent_access)
      end
    end
  end
end
