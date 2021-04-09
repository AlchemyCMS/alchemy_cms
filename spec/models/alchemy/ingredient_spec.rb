# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredient do
  let(:element) do
    build(:alchemy_element, name: "element_with_ingredients", autogenerate_ingredients: false)
  end

  describe ".build" do
    subject { described_class.build(attributes) }

    context "without element" do
      let(:attributes) { {} }

      it { expect { subject }.to raise_error(ArgumentError) }
    end

    context "with element" do
      context "without role given" do
        let(:attributes) { { element: element } }

        it { expect { subject }.to raise_error(ArgumentError) }
      end

      context "with role given" do
        let(:attributes) { { element: element, role: "headline" } }

        it { is_expected.to be_an(Alchemy::Ingredients::Text) }
      end

      context "with default defined" do
        let(:attributes) { { element: element, role: "headline" } }

        it "sets default value" do
          expect(subject.value).to eq("Hello World")
        end
      end

      context "with undefined role given" do
        let(:attributes) { { element: element, role: "foo" } }

        it { expect { subject }.to raise_error(Alchemy::Ingredient::DefinitionError) }
      end
    end
  end

  describe ".create" do
    subject { described_class.create(attributes) }

    let(:attributes) { { element: element, role: "headline" } }

    it { expect { subject }.to change(Alchemy::Ingredients::Text, :count).by(1) }

    it "returns self" do
      is_expected.to be_an(Alchemy::Ingredients::Text)
    end
  end
end
