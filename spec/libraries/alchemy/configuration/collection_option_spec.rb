# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Configuration::CollectionOption do
  subject(:option) { described_class.new(value:, name: :my_option, item_type:, collection_class:) }

  context "with a set of integers" do
    let(:collection_class) { Set }
    let(:item_type) { :integer }
    let(:value) { [1] }

    describe "#value" do
      subject { option.value }
      it { is_expected.to be_a(Enumerable) }
      it { is_expected.to contain_exactly(1) }
    end
  end

  context "with an array of strings" do
    let(:collection_class) { Array }
    let(:item_type) { :string }
    let(:value) { %w[foo bar] }

    describe "#value" do
      subject { option.value }
      it { is_expected.to be_a(Enumerable) }
      it { is_expected.to contain_exactly("foo", "bar") }
    end
  end

  context "with an array of classes" do
    let(:collection_class) { Array }
    let(:item_type) { :class }
    let(:value) { %w[String] }

    describe "#value" do
      subject { option.value }
      it { is_expected.to be_a(Enumerable) }
      it { is_expected.to contain_exactly(String) }
    end
  end

  describe "#<<" do
    let(:collection_class) { Set }
    let(:item_type) { :integer }
    let(:value) { [1] }

    it "adds an item to the collection" do
      option << 2
      expect(option.value.to_a).to contain_exactly(1, 2)
    end
  end

  describe "#[]" do
    let(:collection_class) { Set }
    let(:item_type) { :integer }
    let(:value) { [1] }

    it "returns the item at the given index" do
      expect(option[0]).to eq(1)
    end
  end

  describe "#concat" do
    let(:collection_class) { Set }
    let(:item_type) { :integer }
    let(:value) { [1] }

    it "adds all items to the collection" do
      option.concat([2, 3])
      expect(option.value.to_a).to contain_exactly(1, 2, 3)
    end

    context "if adding the same value" do
      it "does not add the same value twice" do
        option.concat([1])
        expect(option.value.to_a).to contain_exactly(1)
      end
    end
  end

  describe "#delete" do
    let(:collection_class) { Set }
    let(:item_type) { :integer }
    let(:value) { [1, 2, 3] }

    it "adds all items to the collection" do
      option.delete(2)
      expect(option.value.to_a).to contain_exactly(1, 3)
    end

    context "if removing non existing value" do
      it "does not remove the item" do
        option.delete(4)
        expect(option.value.to_a).to contain_exactly(1, 2, 3)
      end
    end

    context "for a array collection class" do
      let(:collection_class) { Array }

      it "deletes the item" do
        option.delete(2)
        expect(option.value.to_a).to contain_exactly(1, 3)
      end
    end

    context "for a collection of class options" do
      let(:item_type) { :class }
      let(:value) { ["Alchemy::Page", "Alchemy::Element"] }

      it "deletes the item" do
        option.delete("Alchemy::Element")
        expect(option.value.to_a).to contain_exactly("Alchemy::Page".constantize)
      end
    end
  end

  describe "#clear" do
    let(:collection_class) { Set }
    let(:item_type) { :integer }
    let(:value) { [1] }

    it "removes all items from the collection" do
      option.clear
      expect(option.value).to be_empty
    end
  end

  describe "#empty?" do
    let(:collection_class) { Set }
    let(:item_type) { :integer }
    let(:value) { [1] }

    it "returns true if the collection is empty" do
      option.clear
      expect(option.empty?).to be true
    end

    it "returns false if the collection is not empty" do
      expect(option.empty?).to be false
    end
  end
end
