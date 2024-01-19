# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::Richtext do
  it_behaves_like "an alchemy ingredient"

  let(:element) do
    build(:alchemy_element, name: "article", autogenerate_ingredients: false)
  end
  let(:richtext_settings) { {} }

  let(:value) { "<h1 style=\"color: red;\">Hello!</h1><p class=\"green\">Welcome to Peters Petshop.</p>" }

  let(:richtext_ingredient) do
    described_class.new(
      element: element,
      type: described_class.name,
      role: "text",
      value: value
    )
  end

  before do
    allow(richtext_ingredient).to receive(:settings) { richtext_settings }
  end

  it "has a HTML tag free version of body column" do
    richtext_ingredient.save
    expect(richtext_ingredient.stripped_body).to eq("Hello!Welcome to Peters Petshop.")
  end

  it "has a sanitized version of body column" do
    richtext_ingredient.save
    expect(richtext_ingredient.sanitized_body).to eq("<h1>Hello!</h1><p class=\"green\">Welcome to Peters Petshop.</p>")
  end

  context "sanitizing with spaces in a link" do
    let(:value) { "<a href=\"/hello/ \">Hello!</a><p class=\"green\">Welcome to Peters Petshop.</p>" }

    it "won't HTML escape spaces in links" do
      richtext_ingredient.save

      expect(richtext_ingredient.sanitized_body).to eq("<a href=\"/hello/ \">Hello!</a><p class=\"green\">Welcome to Peters Petshop.</p>")
    end
  end

  describe "#custom_tinymce_config" do
    subject { richtext_ingredient.custom_tinymce_config }

    it { is_expected.to eq({}) }

    context "with custom configuration" do
      let(:richtext_settings) { {tinymce: {plugin: "link"}} }
      it { is_expected.to eq({plugin: "link"}) }
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
