# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Configuration::BooleanOption do
  subject { described_class.new(value:, name: :my_option).value }

  context "value is true" do
    let(:value) { true }
    it { is_expected.to be true }
  end

  context "value is nil" do
    let(:value) { nil }
    it { is_expected.to be nil }
  end

  context "value is false " do
    let(:value) { false }
    it { is_expected.to be false }
  end

  context "value is something else" do
    let(:value) { :something }

    it "raises exception" do
      expect { subject }.to raise_exception(TypeError)
    end
  end
end
