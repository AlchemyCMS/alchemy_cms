# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Configuration::ProcOption do
  subject { described_class.new(value:, name: :my_option).value }

  context "value is a lambda" do
    let(:value) { -> { "called" } }
    it { is_expected.to be(value) }
  end

  context "value is nil" do
    let(:value) { nil }
    it { is_expected.to be nil }
  end

  context "value is something else" do
    let(:value) { "a string" }

    it "raises exception" do
      expect { subject }.to raise_exception(
        Alchemy::Configuration::ConfigurationError,
        'Invalid configuration value for my_option: "a string" (expected Proc)'
      )
    end
  end
end
