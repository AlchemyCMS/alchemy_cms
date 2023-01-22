# frozen_string_literal: true

require "shoulda-matchers"

RSpec.shared_examples_for "an alchemy ingredient" do
  let(:element) { build(:alchemy_element, name: "article") }

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

  describe "#settings" do
    subject { ingredient.settings }

    context "without element" do
      let(:element) { nil }

      it { is_expected.to eq({}) }
    end

    context "with element" do
      before do
        expect(element).to receive(:ingredient_definition_for).at_least(:once) do
          {
            settings: {
              linkable: true,
            },
          }.with_indifferent_access
        end
      end

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
      let(:definition) do
        {
          role: "headline",
          type: "Text",
          default: "Hello World",
          settings: {
            linkable: true,
          },
        }.with_indifferent_access
      end

      before do
        expect(element).to receive(:ingredient_definition_for).at_least(:once) do
          definition
        end
      end

      it "returns ingredient definition" do
        is_expected.to eq(definition)
      end
    end
  end
end
