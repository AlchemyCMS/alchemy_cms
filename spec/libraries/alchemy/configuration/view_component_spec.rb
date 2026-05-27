# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Configuration::ViewComponentOption do
  subject { described_class.new(value:, name: :my_option).value }

  context "value is a ViewComponent" do
    let(:value) { Class.new(ViewComponent::Base).new }

    it { is_expected.to be_a ViewComponent::Base }
  end

  context "value is nil" do
    let(:value) { nil }

    it { is_expected.to be nil }
  end

  context "value is something else" do
    let(:value) { "NotAViewComponent" }

    it "raises exception" do
      expect { subject }.to raise_exception(
        Alchemy::Configuration::ConfigurationError,
        'Invalid configuration value for my_option: "NotAViewComponent" (expected ViewComponent::Base)'
      )
    end
  end
end
