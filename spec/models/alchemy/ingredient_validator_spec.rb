# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::IngredientValidator do
  subject(:validate) { described_class.new.validate(ingredient) }

  context "with a ingredient not having any validations" do
    let(:element) { create(:alchemy_element, :with_ingredients) }
    let(:ingredient) { element.ingredients.first }

    before { validate }

    it "does not validate" do
      expect(ingredient.errors).to be_blank
    end
  end

  context "with an ingredient having present validation" do
    let(:element) { create(:alchemy_element, :with_ingredients, name: "all_you_can_eat_ingredients") }
    let(:ingredient) { element.ingredient_by_role(:headline) }

    context "and the value is blank" do
      before { validate }

      it { expect(ingredient.errors).to be_present }
      it { expect(ingredient.errors.messages).to eq(value: ["can't be blank"]) }
    end

    context "and the value is present" do
      before do
        expect(ingredient).to receive(:value) { "Foo" }
        validate
      end

      it { expect(ingredient.errors).to be_blank }
    end
  end

  context "with an ingredient having format validation" do
    let(:element) { create(:alchemy_element, :with_ingredients, name: "all_you_can_eat_ingredients") }
    let(:ingredient) { element.ingredient_by_role(:text) }

    before do
      expect(ingredient).to receive(:value).at_least(:once) { value }
      validate
    end

    context "and the value is matching" do
      let(:value) { "Foo" }

      it { expect(ingredient.errors).to be_blank }
    end

    context "and the value is not matching" do
      let(:value) { "!" }

      it { expect(ingredient.errors).to be_present }
    end
  end

  context "with an ingredient having uniqueness validation" do
    let(:element) { create(:alchemy_element, :with_ingredients, name: "all_you_can_eat_ingredients") }
    let(:ingredient) { element.ingredient_by_role(:select) }

    context "and no other ingredient of same kind has the value" do
      before { ingredient.update(value: "B") }

      it { expect(ingredient.errors).to be_blank }
    end

    context "and another ingredient of same kind has the value" do
      let(:element2) { create(:alchemy_element, :with_ingredients, name: "all_you_can_eat_ingredients") }

      let!(:ingredient2) do
        element2.ingredient_by_role(:select).tap do |in2|
          in2.update!(value: "B")
        end
      end

      before do
        ingredient.update(value: "B")
      end

      it { expect(ingredient.errors).to be_present }
      it { expect(ingredient.errors.messages).to eq(value: ["has already been taken"]) }
    end
  end
end
