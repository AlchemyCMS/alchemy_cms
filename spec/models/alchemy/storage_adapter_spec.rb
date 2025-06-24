require "rails_helper"

RSpec.describe Alchemy::StorageAdapter do
  describe "#initialize" do
    it "sets the name and adapter for :active_storage" do
      adapter = described_class.new("active_storage")
      expect(adapter.name).to eq(:active_storage)
      expect(adapter.adapter).to eq(Alchemy::StorageAdapter::ActiveStorage)
    end

    it "sets the name and adapter for :dragonfly" do
      adapter = described_class.new("dragonfly")
      expect(adapter.name).to eq(:dragonfly)
      expect(adapter.adapter).to eq(Alchemy::StorageAdapter::Dragonfly)
    end

    it "raises UnknownAdapterError for unknown adapter" do
      expect {
        described_class.new(:unknown)
      }.to raise_error(Alchemy::StorageAdapter::UnknownAdapterError, /Unknown storage adapter: unknown/)
    end
  end

  describe "#active_storage?" do
    subject(:active_storage?) { adapter.active_storage? }

    context "if active_storage adapter is used" do
      let(:adapter) { described_class.new("active_storage") }

      it { is_expected.to be(true) }
    end
  end

  describe "#dragonfly?" do
    subject(:dragonfly?) { adapter.dragonfly? }

    context "if dragonfly adapter is used" do
      let(:adapter) { described_class.new("dragonfly") }

      it { is_expected.to be(true) }
    end
  end

  describe "#==" do
    let(:adapter) { described_class.new(:dragonfly) }

    it "returns true if the name matches" do
      expect(adapter == :dragonfly).to be true
      expect(adapter == "dragonfly").to be true
    end

    it "returns false if the names do not match" do
      expect(adapter == :foo).to be false
    end
  end
end
