# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Configuration::NumberOption do
  subject { described_class.new(value:, name: :my_option).value }

  context "value is an integer" do
    let(:value) { 4 }
    it { is_expected.to eq 4 }
  end

  context "value is a float" do
    let(:value) { 4.1 }
    it { is_expected.to eq 4.1 }
  end

  context "value is nil" do
    let(:value) { nil }
    it { is_expected.to be nil }
  end

  context "value is something else" do
    let(:value) { "4" }

    it "raises exception" do
      expect { subject }.to raise_exception(
        Alchemy::Configuration::ConfigurationError,
        'Invalid configuration value for my_option: "4" (expected Numeric)'
      )
    end
  end
end
