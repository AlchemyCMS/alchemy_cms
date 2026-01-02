# frozen_string_literal: true

require "rails_helper"
require "alchemy/configurations/main"

class MyCustomUser
end

RSpec.describe Alchemy::Configurations::Main do
  subject(:configuration) { described_class.new }

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

  describe ".user_class" do
    before do
      subject.user_class = "Alchemy::MyCustomUser"
    end

    it "raises error if user_class is not a String" do
      expect {
        subject.user_class = DummyUser
      }.to raise_error(Alchemy::Configuration::ConfigurationError)
    end

    it "returns user_class_name with :: prefix" do
      expect(subject.user_class_name).to eq("::Alchemy::MyCustomUser")
    end
  end

  describe ".user_class" do
    before do
      subject.user_class = "DummyUser"
    end

    context "and the custom User class exists" do
      it "returns the custom user class" do
        expect(subject.user_class).to be(::DummyUser)
      end
    end

    context "and the custom user class does not exist" do
      before do
        subject.user_class = "NoUser"
      end

      it "raises a NameError" do
        expect { subject.user_class }.to raise_exception(NameError)
      end
    end
  end

  describe "defaults" do
    it "has default value for user_class_primary_key" do
      expect(subject.user_class_primary_key).to eq(:id)
    end

    it "has default value for signup_path" do
      expect(subject.signup_path).to eq("/signup")
    end

    it "has default value for login_path" do
      expect(subject.login_path).to eq("/login")
    end

    it "has default value for logout_path" do
      expect(subject.logout_path).to eq("/logout")
    end

    it "has default value for logout_method" do
      expect(subject.logout_method).to eq("delete")
    end
  end
end
