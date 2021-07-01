# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::Text do
  it_behaves_like "an alchemy ingredient"

  let(:element) { build(:alchemy_element, name: "element_with_ingredients") }

  let(:text_ingredient) do
    described_class.new(
      element: element,
      type: described_class.name,
      role: "headline",
      value: "A brown fox quickly jumps over the lazy dog",
      data: {
        link: "https://example.com",
        link_target: "_blank",
        link_title: "Click here",
        link_class_name: "button",
      },
    )
  end

  describe "#link" do
    subject { text_ingredient.link }

    it { is_expected.to eq("https://example.com") }
  end

  describe "#link_target" do
    subject { text_ingredient.link_target }

    it { is_expected.to eq("_blank") }
  end

  describe "#link_title" do
    subject { text_ingredient.link_title }

    it { is_expected.to eq("Click here") }
  end

  describe "#link_class_name" do
    subject { text_ingredient.link_class_name }

    it { is_expected.to eq("button") }
  end

  describe "#link=" do
    before { text_ingredient.link = "https://foobar.io" }
    subject { text_ingredient.link }
    it { is_expected.to eq("https://foobar.io") }
  end

  describe "#link_target=" do
    before { text_ingredient.link_target = "" }
    subject { text_ingredient.link_target }
    it { is_expected.to eq("") }
  end

  describe "#link_title=" do
    before { text_ingredient.link_title = "Follow me" }
    subject { text_ingredient.link_title }
    it { is_expected.to eq("Follow me") }
  end

  describe "#link_class_name=" do
    before { text_ingredient.link_class_name = "btn btn-default" }
    subject { text_ingredient.link_class_name }
    it { is_expected.to eq("btn btn-default") }
  end

  describe "preview_text" do
    subject { text_ingredient.preview_text }

    it "returns the first 30 chars of the value" do
      is_expected.to eq("A brown fox quickly jumps over")
    end
  end
end
