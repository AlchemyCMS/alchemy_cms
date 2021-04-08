# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::Page do
  it_behaves_like "an alchemy ingredient"

  let(:element) { build(:alchemy_element) }
  let(:page) { build(:alchemy_page) }

  let(:page_ingredient) do
    described_class.new(
      element: element,
      type: described_class.name,
      role: "follow_up",
      related_object: page,
    )
  end

  describe "page" do
    subject { page_ingredient.page }

    it { is_expected.to be_an(Alchemy::Page) }
  end

  describe "page=" do
    let(:page) { Alchemy::Page.new }

    subject { page_ingredient.page = page }

    it { is_expected.to be(page) }
  end

  describe "preview_text" do
    subject { page_ingredient.preview_text }

    context "with a page" do
      let(:page) do
        Alchemy::Page.new(name: "A very long page name that would not fit")
      end

      it "returns first 30 characters of the pages name" do
        is_expected.to eq("A very long page name that wou")
      end
    end

    context "with no page" do
      let(:page) { nil }

      it { is_expected.to eq("") }
    end
  end

  describe "value" do
    subject { page_ingredient.value }

    context "with page assigned" do
      it "returns page" do
        is_expected.to be(page)
      end
    end

    context "with no page assigned" do
      let(:page) { nil }

      it { is_expected.to be_nil }
    end
  end
end
