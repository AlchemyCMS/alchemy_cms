# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::Richtext do
  it_behaves_like "an alchemy ingredient"

  let(:element) do
    build(:alchemy_element, name: "element_with_ingredients", autogenerate_ingredients: false)
  end

  let(:richtext_ingredient) do
    described_class.new(
      element: element,
      type: described_class.name,
      role: "text",
      value: "<h1 style=\"color: red;\">Hello!</h1><p class=\"green\">Welcome to Peters Petshop.</p>",
    )
  end

  it "has a HTML tag free version of body column" do
    richtext_ingredient.save
    expect(richtext_ingredient.stripped_body).to eq("Hello!Welcome to Peters Petshop.")
  end

  it "has a sanitized version of body column" do
    richtext_ingredient.save
    expect(richtext_ingredient.sanitized_body).to eq("<h1>Hello!</h1><p class=\"green\">Welcome to Peters Petshop.</p>")
  end

  describe "#tinymce_class_name" do
    subject { richtext_ingredient.tinymce_class_name }

    it { is_expected.to eq("has_tinymce") }

    context "having custom tinymce config" do
      before do
        expect(richtext_ingredient).to receive(:settings) do
          { tinymce: { toolbar: [] } }
        end
      end

      it "returns role including element name" do
        is_expected.to eq("has_tinymce element_with_ingredients_text")
      end
    end
  end

  describe "#has_tinymce?" do
    subject { richtext_ingredient.has_tinymce? }

    it { is_expected.to be(true) }
  end

  describe "preview_text" do
    subject { richtext_ingredient.tap(&:save).preview_text }

    it "returns the first 30 chars of the stripped body column" do
      is_expected.to eq("Hello!Welcome to Peters Petsho")
    end
  end
end
