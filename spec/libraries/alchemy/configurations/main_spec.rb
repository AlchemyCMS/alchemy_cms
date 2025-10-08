# frozen_string_literal: true

require "rails_helper"
require "alchemy/configurations/main"

RSpec.describe Alchemy::Configurations::Main do
  describe "#set_from_yaml" do
    let(:fixture_file) do
      Rails.root.join("..", "fixtures", "config.yml")
    end

    subject { described_class.new }

    before { subject.set_from_yaml(fixture_file) }

    it "has data from the yaml file" do
      expect(subject.auto_logout_time).to eq(20)
    end
  end

  describe "deprecated: #output_image_jpg_quality getter" do
    it "warns and tells us about the right method" do
      expect(Alchemy::Deprecation).to receive(:warn).at_least(:once)
      expect(subject.output_image_jpg_quality).to eq(85)
    end
  end

  describe "deprecated: #output_image_jpg_quality setter" do
    it "warns and tells us about the right method" do
      expect(Alchemy::Deprecation).to receive(:warn).at_least(:once)
      expect do
        subject.output_image_jpg_quality = 90
      end.to change { subject.output_image_quality }.from(85).to(90)
    end
  end

  describe "default values" do
    let(:configuration) { described_class.new }

    describe "#page_searchable_checkbox" do
      subject { configuration.show_page_searchable_checkbox }
      it { is_expected.to be false }
    end
  end

  describe ".admin_importmaps" do
    subject { described_class.new.admin_importmaps }

    it "returns a Set of admin importmaps" do
      is_expected.to be_a(Alchemy::Configuration::CollectionOption)
    end
  end
end
