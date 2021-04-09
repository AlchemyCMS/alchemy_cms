# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Element do
  it { is_expected.to have_many(:ingredients) }

  let(:element) { build(:alchemy_element, name: "element_with_ingredients") }

  it "creates ingredients after creation" do
    expect {
      element.save!
    }.to change { element.ingredients.count }.by(2)
  end

  describe "#ingredients_by_type" do
    let(:element) { create(:alchemy_element, :with_ingredients) }
    let(:expected_ingredients) { element.ingredients.texts }

    context "with namespaced essence type" do
      subject { element.ingredients_by_type("Alchemy::Text") }

      it { is_expected.not_to be_empty }

      it("should return the correct list of essences") { is_expected.to eq(expected_ingredients) }
    end

    context "without namespaced essence type" do
      subject { element.ingredients_by_type("Text") }

      it { is_expected.not_to be_empty }

      it("should return the correct list of essences") { is_expected.to eq(expected_ingredients) }
    end
  end

  describe "#ingredient_by_type" do
    let!(:element) { create(:alchemy_element, :with_ingredients) }
    let(:ingredient) { element.ingredients.first }

    context "with namespaced essence type" do
      it "should return ingredient by passing a essence type" do
        expect(element.ingredient_by_type("Alchemy::Text")).to eq(ingredient)
      end
    end

    context "without namespaced essence type" do
      it "should return ingredient by passing a essence type" do
        expect(element.ingredient_by_type("Text")).to eq(ingredient)
      end
    end
  end

  describe "#ingredient_by_role" do
    let!(:element) { create(:alchemy_element, :with_ingredients) }
    let(:ingredient) { element.ingredients.first }

    context "with role existing" do
      it "should return ingredient" do
        expect(element.ingredient_by_role(:headline)).to eq(ingredient)
      end
    end

    context "role not existing" do
      it { expect(element.ingredient_by_role(:foo)).to be_nil }
    end
  end

  describe "#has_value_for?" do
    let!(:element) { create(:alchemy_element, :with_ingredients) }

    context "with role existing" do
      let(:ingredient) { element.ingredients.first }

      context "with blank value" do
        before do
          expect(ingredient).to receive(:value) { nil }
        end

        it { expect(element.has_value_for?(:headline)).to be(false) }
      end

      context "with value present" do
        before do
          expect(ingredient).to receive(:value) { "Headline" }
        end

        it "should return ingredient" do
          expect(element.has_value_for?(:headline)).to be(true)
        end
      end
    end

    context "role not existing" do
      it { expect(element.has_value_for?(:foo)).to be(false) }
    end
  end
end
