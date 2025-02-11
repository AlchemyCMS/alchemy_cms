# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Configuration::CollectionOption do
  subject(:option) { described_class.new(value:, name: :my_option, item_class:, collection_class:) }

  context "with a set of integers" do
    let(:collection_class) { Set }
    let(:item_class) { Integer }
    let(:value) { [1] }

    describe "#value" do
      subject { option.value }
      it { is_expected.to be_a(Set) }
      it { is_expected.to contain_exactly(1) }
    end
  end

  context "with an array of strings" do
    let(:collection_class) { Array }
    let(:item_class) { String }
    let(:value) { %w[foo bar] }

    describe "#value" do
      subject { option.value }
      it { is_expected.to be_a(Array) }
      it { is_expected.to contain_exactly("foo", "bar") }
    end
  end

  context "with an array of configurations" do
    let(:collection_class) { Array }
    let(:item_class) { Alchemy::Configurations::Sitemap }
    let(:value) do
      [
        Alchemy::Configurations::Sitemap.new(
          show_root: true,
          show_flag: false
        )
      ]
    end

    it "contains configurations" do
      expect(subject.value.first.show_root).to be true
    end
  end
end
