# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Configuration::SymbolOption do
  subject { described_class.new(value:, name: :my_option).value }

  context "value is :symbol" do
    let(:value) { :symbol }
    it { is_expected.to be :symbol }
  end

  context "value is nil" do
    let(:value) { nil }
    it { is_expected.to be nil }
  end

  context "value is something else" do
    let(:value) { "string" }

    it "raises exception" do
      expect { subject }.to raise_exception(
        Alchemy::Configuration::ConfigurationError,
        'Invalid configuration value for my_option: "string" (expected Symbol)'
      )
    end
  end
end
