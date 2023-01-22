# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Element do
  it { is_expected.to have_many(:ingredients) }

  let(:element) { build(:alchemy_element, :with_ingredients) }

  it "creates ingredients after creation" do
    expect {
      element.save!
    }.to change { element.ingredients.count }.by(4)
  end

  describe "#ingredients_by_type" do
    let(:element) { create(:alchemy_element, :with_ingredients) }
    let(:expected_ingredients) { element.ingredients.texts }

    context "with namespaced type" do
      subject { element.ingredients_by_type("Alchemy::Text") }

      it { is_expected.not_to be_empty }

      it "should return the correct list of ingredients" do
        is_expected.to eq(expected_ingredients)
      end
    end

    context "without namespaced type" do
      subject { element.ingredients_by_type("Text") }

      it { is_expected.not_to be_empty }

      it "should return the correct list of ingredients" do
        is_expected.to eq(expected_ingredients)
      end
    end
  end

  describe "#ingredient_by_type" do
    let!(:element) { create(:alchemy_element, :with_ingredients) }
    let(:ingredient) { element.ingredients.find_by!(type: "Alchemy::Ingredients::Text") }

    context "with namespaced type" do
      it "should return ingredient by passing a type" do
        expect(element.ingredient_by_type("Alchemy::Ingredients::Text")).to eq(ingredient)
      end
    end

    context "without namespaced type" do
      it "should return ingredient by passing a type" do
        expect(element.ingredient_by_type("Text")).to eq(ingredient)
      end
    end
  end

  describe "#ingredient_by_role" do
    let!(:element) { create(:alchemy_element, :with_ingredients) }
    let(:ingredient) { element.ingredients.find_by!(role: "headline") }

    context "with role existing" do
      it "should return ingredient" do
        expect(element.ingredient_by_role(:headline)).to eq(ingredient)
      end
    end

    context "role not existing" do
      it { expect(element.ingredient_by_role(:foo)).to be_nil }
    end
  end

  describe "#value_for" do
    let!(:element) { create(:alchemy_element, :with_ingredients) }

    context "with role existing" do
      let(:ingredient) { element.ingredient_by_role(:headline) }

      context "with blank value" do
        before do
          expect(ingredient).to receive(:value) { nil }
        end

        it { expect(element.value_for(:headline)).to be_nil }
      end

      context "with value present" do
        before do
          expect(ingredient).to receive(:value) { "Headline" }
        end

        it "should return value" do
          expect(element.value_for(:headline)).to eq("Headline")
        end
      end
    end

    context "role not existing" do
      it { expect(element.value_for(:foo)).to be_nil }
    end
  end

  describe "#has_value_for?" do
    let!(:element) do
      create(:alchemy_element, :with_ingredients, name: "all_you_can_eat")
    end

    context "with role existing" do
      let(:ingredient) { element.ingredient_by_role(:headline) }

      context "with blank value" do
        it { expect(element.has_value_for?(:headline)).to be(false) }
      end

      context "with value present" do
        before do
          ingredient.value = "Headline"
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

  describe "ingredient validations" do
    let(:element) { create(:alchemy_element, :with_ingredients, name: "all_you_can_eat") }

    before do
      element.update(
        ingredients_attributes: {
          "0": {
            id: element.ingredients.first.id,
            value: "",
          },
        },
      )
    end

    it "validates ingredients on update" do
      expect(element.errors[:ingredients]).to be_present
    end
  end

  describe "#ingredient_error_messages" do
    let(:element) { create(:alchemy_element, :with_ingredients, name: "all_you_can_eat") }

    before do
      element.update(
        ingredients_attributes: {
          "0": {
            id: element.ingredients.first.id,
            value: "",
          },
        },
      )
    end

    it "returns translated ingredient error messages" do
      expect(element.ingredient_error_messages).to eq([
        "Please enter a headline for all you can eat",
        "Text is invalid",
      ])
    end
  end

  describe "#richtext_ingredients_ids" do
    subject { element.richtext_ingredients_ids }

    let(:element) { create(:alchemy_element, :with_ingredients, name: "text") }

    it { is_expected.to eq(element.ingredient_ids) }

    context "for element with nested elements" do
      let!(:element) do
        create(:alchemy_element, :with_ingredients, name: "text")
      end

      let!(:nested_element_1) do
        create(:alchemy_element, :with_ingredients, {
          name: "text",
          parent_element: element,
          folded: false,
        })
      end

      let!(:nested_element_2) do
        create(:alchemy_element, :with_ingredients, {
          name: "text",
          parent_element: nested_element_1,
          folded: false,
        })
      end

      let!(:folded_nested_element_3) do
        create(:alchemy_element, :with_ingredients, {
          name: "text",
          parent_element: nested_element_1,
          folded: true,
        })
      end

      it "includes all richtext ingredients from all expanded descendent elements" do
        is_expected.to eq(
          element.ingredient_ids +
          nested_element_1.ingredient_ids +
          nested_element_2.ingredient_ids,
        )
      end
    end
  end
end
