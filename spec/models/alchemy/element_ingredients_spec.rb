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

  describe "#ingredients_attributes=" do
    let(:element) { create(:alchemy_element, :with_ingredients) }
    let(:headline) { element.ingredient_by_role(:headline) }
    let(:image) { element.ingredient_by_role(:image) }
    let(:picture) { create(:alchemy_picture) }

    it "updates the value, data store keys and related object of existing ingredients" do
      element.update!(ingredients_attributes: {
        "0" => {id: headline.id, value: "Hello", level: "3"},
        "1" => {id: image.id, picture_id: picture.id, crop_from: "0x0"}
      })

      expect(headline.reload).to have_attributes(value: "Hello", level: "3")
      expect(image.reload).to have_attributes(picture: picture, crop_from: "0x0")
    end

    it "ignores ingredient columns other than value" do
      other_element = create(:alchemy_element)
      user = create(:alchemy_dummy_user)

      element.update!(ingredients_attributes: [{
        id: headline.id,
        value: "<script>alert(1)</script>",
        type: "Alchemy::Ingredients::Html",
        role: "hijacked",
        element_id: other_element.id,
        related_object_type: "DummyUser",
        related_object_id: user.id,
        data: {hijacked: true}
      }])

      ingredient = Alchemy::Ingredient.find(headline.id)
      expect(ingredient).to have_attributes(
        class: Alchemy::Ingredients::Headline,
        value: "<script>alert(1)</script>",
        role: "headline",
        element_id: element.id,
        related_object_type: nil,
        related_object_id: nil
      )
      expect(ingredient.data).not_to have_key("hijacked")
    end

    it "ignores attributes the ingredient's class does not allow" do
      element.update!(ingredients_attributes: [{id: headline.id, value: "Hello", picture_id: picture.id}])

      expect(Alchemy::Ingredient.find(headline.id)).to have_attributes(
        value: "Hello",
        related_object_id: nil
      )
    end

    it "does not create new ingredients" do
      expect {
        element.update!(ingredients_attributes: {
          "0" => {type: "Alchemy::Ingredients::Html", role: "injected", value: "<script>alert(1)</script>"}
        })
      }.not_to change { element.ingredients.count }
    end
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
            value: ""
          }
        }
      )
    end

    it "validates ingredients on update" do
      expect(element.errors[:ingredients]).to be_present
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
          folded: false
        })
      end

      let!(:nested_element_2) do
        create(:alchemy_element, :with_ingredients, {
          name: "text",
          parent_element: nested_element_1,
          folded: false
        })
      end

      let!(:folded_nested_element_3) do
        create(:alchemy_element, :with_ingredients, {
          name: "text",
          parent_element: nested_element_1,
          folded: true
        })
      end

      it "includes all richtext ingredients from all expanded descendent elements" do
        is_expected.to eq(
          element.ingredient_ids +
          nested_element_1.ingredient_ids +
          nested_element_2.ingredient_ids
        )
      end

      context "when all_nested_elements is preloaded" do
        subject do
          Alchemy::Element.preload(:all_nested_elements, ingredients: :related_object)
            .find(element.id)
            .richtext_ingredients_ids
        end

        it "includes all richtext ingredients from all expanded descendent elements" do
          is_expected.to eq(
            element.ingredient_ids +
            nested_element_1.ingredient_ids +
            nested_element_2.ingredient_ids
          )
        end
      end
    end
  end
end
