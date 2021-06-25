# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::Picture do
  it_behaves_like "an alchemy ingredient"

  let(:element) { build_stubbed(:alchemy_element, name: "all_you_can_eat_ingredients") }
  let(:picture) { build_stubbed(:alchemy_picture) }

  let(:picture_ingredient) do
    described_class.new(
      element: element,
      type: described_class.name,
      role: "image",
      related_object: picture,
    )
  end

  describe "alt_tag" do
    before { picture_ingredient.alt_tag = "A cute kitten" }
    subject { picture_ingredient.alt_tag }

    it { is_expected.to eq("A cute kitten") }
  end

  describe "css_class" do
    before { picture_ingredient.css_class = "download" }
    subject { picture_ingredient.css_class }

    it { is_expected.to eq("download") }
  end

  describe "link_title" do
    before { picture_ingredient.link_title = "Nice picture" }
    subject { picture_ingredient.link_title }

    it { is_expected.to eq("Nice picture") }
  end

  describe "title" do
    before { picture_ingredient.title = "Click to view" }
    subject { picture_ingredient.title }

    it { is_expected.to eq("Click to view") }
  end

  describe "picture" do
    subject { picture_ingredient.picture }

    it { is_expected.to be_an(Alchemy::Picture) }
  end

  describe "picture=" do
    let(:picture) { Alchemy::Picture.new }

    subject { picture_ingredient.picture = picture }

    it { is_expected.to be(picture) }
  end

  describe "#picture_id" do
    subject { picture_ingredient.picture_id }

    it {
      is_expected.to be_an(Integer)
    }
  end

  describe "#picture_id=" do
    let(:picture) { Alchemy::Picture.new(id: 111) }

    subject { picture_ingredient.picture_id = picture.id }

    it { is_expected.to be(111) }
    it { expect(picture_ingredient.related_object_type).to eq("Alchemy::Picture") }
  end

  describe "preview_text" do
    subject { picture_ingredient.preview_text }

    context "with a picture" do
      let(:picture) do
        Alchemy::Picture.new(name: "A very long picture name that would not fit")
      end

      it "returns first 30 characters of the picture name" do
        is_expected.to eq("A very long picture name that ")
      end
    end

    context "with no picture" do
      let(:picture) { nil }

      it { is_expected.to eq("") }
    end
  end

  describe "value" do
    subject { picture_ingredient.value }

    context "with picture assigned" do
      it "returns picture" do
        is_expected.to be(picture)
      end
    end

    context "with no picture assigned" do
      let(:picture) { nil }

      it { is_expected.to be_nil }
    end
  end

  it_behaves_like "having picture thumbnails" do
    let(:element) { build(:alchemy_element, name: "all_you_can_eat_ingredients") }
    let(:picture) { build(:alchemy_picture) }

    let(:record) do
      described_class.new(
        element: element,
        type: described_class.name,
        role: "picture",
        picture: picture,
      )
    end
  end
end
