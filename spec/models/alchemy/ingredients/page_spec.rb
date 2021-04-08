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
end
