# frozen_string_literal: true

require "rails_helper"

MyClass = Class.new do
  def self.name
    "MyClass"
  end
end

RSpec.describe Alchemy::Configuration::ClassOption do
  subject { described_class.new(value:, name: :my_class).value }

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

  after do
    if defined?(MyClass)
      Object.send(:remove_const, :MyClass)
    end
  end
end
