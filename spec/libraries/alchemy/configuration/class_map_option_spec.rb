# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Configuration::ClassMapOption do
  subject(:option) { described_class.new(value:, name: :ingredient_preloaders) }

  before do
    stub_const("MyPreloader", Class.new)
    stub_const("AnotherPreloader", Class.new)
  end

  context "with a populated hash" do
    let(:value) { {"Alchemy::Ingredients::Text" => "MyPreloader"} }

    describe "#value" do
      it "returns self so the option acts as the map" do
        expect(option.value).to be(option)
      end
    end

    describe "#[]" do
      it "constantizes the value on first access" do
        expect(option["Alchemy::Ingredients::Text"]).to be MyPreloader
      end

      it "returns nil for an absent key" do
        expect(option["Alchemy::Ingredients::Picture"]).to be nil
      end

      it "accepts symbol keys by coercing them to strings" do
        expect(option[:"Alchemy::Ingredients::Text"]).to be MyPreloader
      end
    end

    describe "#[]=" do
      it "adds a new mapping at runtime" do
        option["Alchemy::Ingredients::Picture"] = "AnotherPreloader"
        expect(option["Alchemy::Ingredients::Picture"]).to be AnotherPreloader
      end

      it "replaces an existing mapping" do
        option["Alchemy::Ingredients::Text"] = "AnotherPreloader"
        expect(option["Alchemy::Ingredients::Text"]).to be AnotherPreloader
      end

      it "invalidates the constantize cache for the replaced key" do
        # Prime the cache
        expect(option["Alchemy::Ingredients::Text"]).to be MyPreloader
        option["Alchemy::Ingredients::Text"] = "AnotherPreloader"
        expect(option["Alchemy::Ingredients::Text"]).to be AnotherPreloader
      end
    end

    describe "#fetch" do
      it "returns the constantized class when the key is present" do
        expect(option.fetch("Alchemy::Ingredients::Text")).to be MyPreloader
      end

      it "returns the default when the key is absent" do
        expect(option.fetch("Missing::Key", :default)).to eq :default
      end

      it "returns nil default when no default given and key absent" do
        expect(option.fetch("Missing::Key")).to be nil
      end
    end

    describe "#merge!" do
      it "adds all pairs from the given hash" do
        option["Alchemy::Ingredients::Picture"] = "AnotherPreloader"
        expect(option["Alchemy::Ingredients::Picture"]).to be AnotherPreloader
        expect(option["Alchemy::Ingredients::Text"]).to be MyPreloader
      end

      it "returns self" do
        expect(option.merge!({})).to be(option)
      end
    end

    describe "#key?" do
      it "returns true for a present key" do
        expect(option.key?("Alchemy::Ingredients::Text")).to be true
      end

      it "returns false for an absent key" do
        expect(option.key?("Alchemy::Ingredients::Picture")).to be false
      end
    end

    describe "#keys" do
      it "returns all string keys" do
        expect(option.keys).to eq(["Alchemy::Ingredients::Text"])
      end
    end

    describe "#each / #each_pair" do
      it "yields [key, constantized_class] pairs" do
        pairs = []
        option.each { |k, v| pairs << [k, v] }
        expect(pairs).to eq([["Alchemy::Ingredients::Text", MyPreloader]])
      end

      it "is aliased as each_pair" do
        pairs = []
        option.each_pair { |k, v| pairs << [k, v] }
        expect(pairs).to eq([["Alchemy::Ingredients::Text", MyPreloader]])
      end
    end

    describe "#empty?" do
      it "returns false when the map has entries" do
        expect(option.empty?).to be false
      end
    end

    describe "#size / #length" do
      it "returns the number of entries" do
        expect(option.size).to eq 1
        expect(option.length).to eq 1
      end
    end

    describe "#raw_value" do
      it "returns the raw string-keyed, string-value hash without constantizing" do
        expect(option.raw_value).to eq({"Alchemy::Ingredients::Text" => "MyPreloader"})
      end
    end

    describe "#to_serializable_hash" do
      it "returns the raw string hash suitable for serialization" do
        expect(option.to_serializable_hash).to eq({"Alchemy::Ingredients::Text" => "MyPreloader"})
      end
    end
  end

  context "with nil value" do
    let(:value) { nil }

    it "initializes to an empty map" do
      expect(option.empty?).to be true
    end
  end

  context "with an empty hash" do
    let(:value) { {} }

    describe "#empty?" do
      it "returns true" do
        expect(option.empty?).to be true
      end
    end
  end

  context "with a non-Hash value" do
    let(:value) { "not a hash" }

    it "raises a ConfigurationError" do
      expect { option }.to raise_error(
        Alchemy::Configuration::ConfigurationError,
        /Invalid configuration value for ingredient_preloaders/
      )
    end
  end

  describe "equality" do
    let(:value) { {"Alchemy::Ingredients::Text" => "MyPreloader"} }

    it "equals another option with the same raw value" do
      other = described_class.new(value: {"Alchemy::Ingredients::Text" => "MyPreloader"}, name: :ingredient_preloaders)
      expect(option).to eq(other)
    end

    it "does not equal an option with a different raw value" do
      other = described_class.new(value: {}, name: :ingredient_preloaders)
      expect(option).not_to eq(other)
    end
  end
end
