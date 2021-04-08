# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::Link do
  it_behaves_like "an alchemy ingredient"

  let(:element) { build(:alchemy_element) }

  let(:link_ingredient) do
    described_class.new(
      element: element,
      type: described_class.name,
      role: "headline",
      value: "https://example.com",
      data: {
        link_target: "_blank",
        link_title: "Click here",
        link_class_name: "button",
      },
    )
  end

  describe "#link_target" do
    subject { link_ingredient.link_target }

    it { is_expected.to eq("_blank") }
  end

  describe "#link_title" do
    subject { link_ingredient.link_title }

    it { is_expected.to eq("Click here") }
  end

  describe "#link_class_name" do
    subject { link_ingredient.link_class_name }

    it { is_expected.to eq("button") }
  end

  describe "#link_target=" do
    subject { link_ingredient.link_target = "" }

    it { is_expected.to eq("") }
  end

  describe "#link_title=" do
    subject { link_ingredient.link_title = "Follow me" }

    it { is_expected.to eq("Follow me") }
  end

  describe "#link_class_name=" do
    subject { link_ingredient.link_class_name = "btn btn-default" }

    it { is_expected.to eq("btn btn-default") }
  end

  describe "preview_text" do
    subject { link_ingredient.preview_text }

    it "returns first 30 characters of the value" do
      is_expected.to eq("https://example.com")
    end
  end
end
