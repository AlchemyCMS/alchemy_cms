# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Configuration::ConfigurationOption do
  subject(:option) { described_class.new(value:, name: :my_config, config_class: Alchemy::Configurations::Sitemap) }

  describe "#value" do
    subject { option.value }

    context "with a hash" do
      let(:value) { {show_root: true, show_flag: false} }

      it { is_expected.to respond_to(:show_root) }
      it { is_expected.to respond_to(:show_flag) }
    end

    context "with a hash with string keys" do
      let(:value) { {"show_root" => true, "show_flag" => false} }

      it { is_expected.to respond_to(:show_root) }
      it { is_expected.to respond_to(:show_flag) }
    end

    context "with a sitemap configuration object" do
      let(:value) { Alchemy::Configurations::Sitemap.new }

      it { is_expected.to respond_to(:show_root) }
      it { is_expected.to respond_to(:show_flag) }
    end

    context "initialized with nil" do
      let(:value) { nil }

      it "raises an exception" do
        expect { subject }.to raise_exception(
          Alchemy::Configuration::ConfigurationError,
          "Invalid configuration value for my_config: nil (expected Hash or Alchemy::Configurations::Sitemap)"
        )
      end
    end
  end

  describe "Using within a set" do
    let(:value) { {show_root: true, show_flag: false} }
    let(:option_2) { described_class.new(value: value, name: :my_config, config_class: Alchemy::Configurations::Sitemap) }

    it "should have the same hash value" do
      expect(option.hash).to eq(option_2.hash)
    end

    it "should be able to add the option to a set" do
      expect(option).to eql(option_2)
      expect(Set.new([option, option_2])).to include(option)
      expect(Set.new([option, option_2]).length).to eq(1)
    end
  end
end
