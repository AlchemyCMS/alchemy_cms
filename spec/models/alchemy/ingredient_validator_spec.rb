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
    let(:element) { create(:alchemy_element, :with_ingredients, name: "all_you_can_eat") }
    let(:ingredient) { element.ingredient_by_role(:headline) }

    context "and the value is blank" do
      before { validate }

      it { expect(ingredient.errors[:value]).to include("can't be blank") }
    end

    context "and the value is present" do
      before do
        expect(ingredient).to receive(:value).at_least(:once) { "Foo" }
        validate
      end

      it { expect(ingredient.errors).to be_blank }
    end
  end

  context "with an ingredient having format validation" do
    let(:element) { create(:alchemy_element, :with_ingredients, name: "all_you_can_eat") }
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

    context "an element with email format validation" do
      let(:element) { create(:alchemy_element, :with_ingredients, name: "contactform") }
      let(:ingredient) { element.ingredient_by_role(:mail_from) }

      context "and the value is matching" do
        let(:value) { "my_email@example.com" }

        it { expect(ingredient.errors).to be_blank }
      end

      context "and the value is not matching" do
        let(:value) { "my_email@example" }

        it { expect(ingredient.errors).to be_present }
      end
    end

    context "and the value is blank" do
      let(:value) { "" }

      it "does not add format validation errors" do
        expect(ingredient.errors).to be_blank
      end
    end
  end

  context "an element with url format validation" do
    let(:element) { create(:alchemy_element, :with_ingredients, name: "element_with_url") }
    let(:ingredient) { element.ingredient_by_role(:url) }

    before do
      expect(ingredient).to receive(:value).at_least(:once) { value }
      validate
    end

    context "with a slash" do
      let(:value) { "www.example.com:80/about" }

      it { expect(ingredient.errors).to be_blank }
    end

    context "and the value is not matching" do
      let(:value) { 'www.example.com:80\/about' }

      it { expect(ingredient.errors).to be_present }
    end
  end

  context "with an ingredient having length validation" do
    let(:element) { create(:alchemy_element, :with_ingredients, name: "all_you_can_eat") }
    let(:ingredient) { element.ingredient_by_role(:headline) }

    before do
      expect(ingredient).to receive(:value).at_least(:once) { value }
      validate
    end

    context "and the value is too short" do
      let(:value) { "Fo" }

      it "has error" do
        expect(ingredient.errors[:value]).to include("is too short (minimum is 3 characters)")
      end
    end

    context "and the value is too long" do
      let(:value) { "a" * 51 }

      it "has error" do
        expect(ingredient.errors[:value]).to include "is too long (maximum is 50 characters)"
      end
    end

    context "and the value is just right" do
      let(:value) { "applejuice" }

      it { expect(ingredient).to be_valid }
    end

    context "and the value is blank" do
      let(:value) { "" }

      it "does not add length validation errors" do
        expect(ingredient.errors[:value]).not_to include("is too short (minimum is 3 characters)")
        expect(ingredient.errors[:value]).not_to include("is too long (maximum is 50 characters)")
      end
    end
  end

  context "with an ingredient having uniqueness validation" do
    let(:element) { create(:alchemy_element, :with_ingredients, name: "all_you_can_eat") }
    let(:ingredient) { element.ingredient_by_role(:select) }

    context "and no other ingredient of same kind has the value" do
      before { ingredient.update(value: "B") }

      it { expect(ingredient.errors).to be_blank }
    end

    context "and another ingredient of same kind has the value" do
      let(:element2) { create(:alchemy_element, :with_ingredients, name: "all_you_can_eat") }

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

    context "and the same value exists in a published page version" do
      let(:page) { create(:alchemy_page, :public) }
      let(:draft_version) { page.draft_version }
      let(:public_version) { page.public_version }

      let(:draft_element) do
        create(:alchemy_element, :with_ingredients, name: "all_you_can_eat", page_version: draft_version)
      end

      let(:ingredient) { draft_element.ingredient_by_role(:select) }

      let!(:public_element) do
        create(:alchemy_element, :with_ingredients, name: "all_you_can_eat", page_version: public_version)
      end

      let!(:public_ingredient) do
        public_element.ingredient_by_role(:select).tap do |ing|
          ing.update!(value: "B")
        end
      end

      before do
        ingredient.update(value: "B")
      end

      it "does not consider the published version as a duplicate" do
        expect(ingredient.errors).to be_blank
      end
    end

    context "and the same value exists in a different language" do
      let(:german) { create(:alchemy_language, :german) }
      let(:german_page) { create(:alchemy_page, language: german) }

      let(:german_element) do
        create(:alchemy_element, :with_ingredients, name: "all_you_can_eat", page_version: german_page.draft_version)
      end

      let!(:german_ingredient) do
        german_element.ingredient_by_role(:select).tap do |ing|
          ing.update!(value: "B")
        end
      end

      before do
        ingredient.update(value: "B")
      end

      it "does not consider the other language as a duplicate" do
        expect(ingredient.errors).to be_blank
      end
    end
  end
end
