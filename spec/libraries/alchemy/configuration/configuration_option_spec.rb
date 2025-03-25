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
end
