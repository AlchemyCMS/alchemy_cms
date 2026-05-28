# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Configuration::ClassOption do
  subject { described_class.new(value:, name: :my_class).value }

  before do
    stub_const("MyClass", Class.new)
  end

  context "value is 'MyClass'" do
    let(:value) { "MyClass" }

    it { is_expected.to be MyClass }
  end

  context "value is nil" do
    let(:value) { nil }

    it { is_expected.to be nil }
  end

  context "value is not a valid class name" do
    let(:value) { "klazz" }

    it "raises exception" do
      expect { subject }.to raise_exception(
        NameError,
        "wrong constant name klazz"
      )
    end
  end

  context "value is an Array" do
    let(:value) { ["MyClass", {foo: "bar"}] }

    context "with two items" do
      it "value is the constantized class with arguments" do
        is_expected.to eq [MyClass, {foo: "bar"}]
      end

      context "first item is not a String" do
        let(:value) { [123, {foo: "bar"}] }

        it "raises exception" do
          expect { subject }.to raise_exception(
            Alchemy::Configuration::ConfigurationError,
            "Invalid configuration value for my_class: 123 (expected String)"
          )
        end
      end

      context "second item is not a Hash" do
        it "raises an exception" do
          expect { described_class.new(value: ["MyClass", "not a hash"], name: :my_class) }.to raise_exception(
            Alchemy::Configuration::ConfigurationError,
            'Invalid configuration value for my_class: "not a hash" (expected Hash)'
          )
        end
      end
    end

    context "with just one item" do
      let(:value) { ["MyClass"] }

      it "raises exception" do
        expect { subject }.to raise_exception(
          Alchemy::Configuration::ConfigurationError,
          'Invalid configuration value for my_class: ["MyClass"] (expected an Array of length two)'
        )
      end
    end
  end
end
