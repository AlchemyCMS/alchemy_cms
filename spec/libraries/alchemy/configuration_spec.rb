# frozen_string_literal: true

require "rails_helper"
require "alchemy/configuration"

RSpec.describe Alchemy::Configuration do
  let(:configuration) do
    Class.new(described_class) do
      option :auto_logout_time, :integer, default: 30
    end.new
  end

  it "has a setter" do
    expect do
      configuration.auto_logout_time = 15
    end.to change { configuration.auto_logout_time }.from(30).to(15)
  end

  it "allows setting the option to nil" do
    expect do
      configuration.auto_logout_time = nil
    end.to change { configuration.auto_logout_time }.from(30).to(nil)
  end

  it "has several getters" do
    expect(configuration["auto_logout_time"]).to eq(30)
    expect(configuration.auto_logout_time).to eq(30)
    expect(configuration.get(:auto_logout_time)).to eq(30)
  end

  it "returns self when #show is called" do
    expect(configuration.show).to eq(configuration)
  end

  context "without a default value" do
    let(:configuration) do
      Class.new(described_class) do
        option :auto_logout_time, :integer
      end.new
    end

    it "defaults to nil" do
      expect(configuration.auto_logout_time).to be nil
    end

    describe "#fetch" do
      it "allows getting data but setting a default, like Hash" do
        expect(configuration.fetch("auto_logout_time", 20)).to eq(20)
        configuration.auto_logout_time = 40
        expect(configuration.fetch("auto_logout_time", 20)).to eq(40)
      end
    end
  end

  context "setting with the wrong type" do
    it "raises an error" do
      expect do
        configuration.auto_logout_time = "14"
      end.to raise_exception(
        Alchemy::Configuration::ConfigurationError,
        'Invalid configuration value for auto_logout_time: "14" (expected Integer)'
      )
    end
  end

  describe "setting classes" do
    let(:configuration) do
      Class.new(described_class) do
        option :picture_thumb_storage_class, :class, default: "Alchemy::PictureThumb::FileStore"
      end.new
    end

    it "returns the constantized class" do
      expect(configuration.picture_thumb_storage_class).to be Alchemy::PictureThumb::FileStore
    end

    it "can only be set using a string" do
      expect do
        configuration.picture_thumb_storage_class = String
      end.to raise_exception(
        Alchemy::Configuration::ConfigurationError,
        "Invalid configuration value for picture_thumb_storage_class: String (expected String)"
      )
    end
  end

  describe "setting and changing class sets" do
    let(:configuration) do
      Class.new(described_class) do
        option :preview_sources, :collection, item_type: :class, default: ["Alchemy::Admin::PreviewUrl"]
      end.new
    end

    it "returns an Enumerable that returns all classes as constants" do
      expect(configuration.preview_sources.to_a).to eq([Alchemy::Admin::PreviewUrl])
    end
  end

  describe "Boolean options" do
    let(:configuration) do
      Class.new(described_class) do
        option :cache_pages, :boolean, default: true
      end.new
    end

    it "returns the boolean" do
      expect(configuration.cache_pages).to be true
    end

    it "can only be set with a Boolean" do
      expect do
        configuration.cache_pages = "true"
      end.to raise_exception(
        Alchemy::Configuration::ConfigurationError,
        'Invalid configuration value for cache_pages: "true" (expected Boolean)'
      )
    end
  end

  describe "integer lists" do
    let(:configuration) do
      Class.new(described_class) do
        option :page_preview_sizes, :collection, item_type: :integer, default: [1, 2]
      end.new
    end

    it "returns the integer list" do
      expect(configuration.page_preview_sizes.to_a).to eq([1, 2])
    end

    it "can only be set with an integer list" do
      expect do
        configuration.page_preview_sizes = ["1"]
      end.to raise_exception(
        Alchemy::Configuration::ConfigurationError,
        'Invalid configuration value for page_preview_sizes: "1" (expected Integer)'
      )
    end
  end

  describe "string lists" do
    let(:configuration) do
      Class.new(described_class) do
        option :link_target_options, :collection, item_type: :string, default: ["blank"]
      end.new
    end

    it "returns the string list" do
      expect(configuration.link_target_options.to_a).to eq(["blank"])
    end

    it "can only be set with an Array of strings" do
      expect do
        configuration.link_target_options = [:blank]
      end.to raise_exception(
        Alchemy::Configuration::ConfigurationError,
        "Invalid configuration value for link_target_options: :blank (expected String)"
      )
    end
  end

  describe "string options" do
    let(:configuration) do
      Class.new(described_class) do
        option :mail_success_page, :string, default: "thanks"
      end.new
    end

    it "returns the string list" do
      expect(configuration.mail_success_page).to eq("thanks")
    end

    it "can only be set with an Array of strings" do
      expect do
        configuration.mail_success_page = :thanks
      end.to raise_exception(
        Alchemy::Configuration::ConfigurationError,
        "Invalid configuration value for mail_success_page: :thanks (expected String)"
      )
    end
  end

  describe "regexp options" do
    let(:configuration) do
      Class.new(described_class) do
        option :email, :regexp, default: /\A.*\z/
      end.new
    end

    it "returns the regexp" do
      expect(configuration.email).to eq(/\A.*\z/)
    end

    it "can only be set with a regexp" do
      expect do
        configuration.email = '/\A.*\z/'
      end.to raise_exception(
        Alchemy::Configuration::ConfigurationError,
        "Invalid configuration value for email: #{'/\A.*\z/'.inspect} (expected Regexp)"
      )
    end
  end

  describe "initializing with a hash" do
    let(:configuration_class) do
      Class.new(described_class) do
        option :mail_success_page, :string, default: "thanks"
        option :link_target_options, :collection, item_type: :string, default: ["blank"]
      end
    end

    let(:configuration) do
      configuration_class.new(mail_success_page: "verymuchthankyou", link_target_options: ["top"])
    end

    it "takes the values from the hash" do
      expect(configuration.mail_success_page).to eq("verymuchthankyou")
      expect(configuration.link_target_options.to_a).to eq(["top"])
    end
  end

  describe "#set" do
    let(:configuration_class) do
      Class.new(described_class) do
        option :mail_success_page, :string, default: "thanks"
        option :link_target_options, :collection, item_type: :string, default: ["blank"]
      end
    end

    let(:configuration) do
      configuration_class.new
    end

    it "takes the values from the hash" do
      configuration.set(mail_success_page: "verymuchthankyou", link_target_options: ["top"])
      expect(configuration.mail_success_page).to eq("verymuchthankyou")
      expect(configuration.link_target_options.to_a).to eq(["top"])
    end
  end

  describe "get" do
    let(:configuration) do
      Class.new(described_class) do
        option :mail_success_page, :string, default: "thanks"
        option :link_target_options, :collection, item_type: :string, default: ["blank"]
      end.new
    end

    subject { configuration.get(:mail_success_page) }

    it { is_expected.to eq("thanks") }

    it "can be converted to a Hash" do
      expect(configuration.to_h).to eq(
        mail_success_page: "thanks",
        link_target_options: ["blank"]
      )
    end
  end

  describe "nested configurations" do
    let(:configuration) do
      uploader_configuration_class = Class.new(described_class) do
        option :file_size_limit, :integer, default: 100
        option :upload_limit, :integer, default: 50
      end

      Class.new(described_class) do
        configuration :uploader, uploader_configuration_class
      end.new
    end

    it "can be accessed as methods" do
      expect(configuration.uploader.upload_limit).to eq(50)
    end

    it "can be accessed with []" do
      expect(configuration[:uploader][:upload_limit]).to eq(50)
    end

    it "can be set using a nested hash" do
      configuration.set(uploader: {upload_limit: 30})
      configuration.set(uploader: {file_size_limit: 80})
      expect(configuration.uploader.upload_limit).to eq(30)
      expect(configuration.uploader.file_size_limit).to eq(80)
    end

    it "can be converted to a Hash" do
      expect(configuration.to_h).to eq(
        uploader: {file_size_limit: 100, upload_limit: 50}
      )
    end
  end

  describe "#preview_sources" do
    let(:configuration) do
      Class.new(described_class) do
        option :preview_sources, :collection, item_type: :class, default: ["Alchemy::Admin::PreviewUrl"]
      end.new
    end

    it "returns an Enumerable that returns all classes as constants" do
      expect(configuration.preview_sources.to_a).to eq([Alchemy::Admin::PreviewUrl])
    end
  end

  describe "#preview_sources=" do
    let(:configuration) do
      Class.new(described_class) do
        option :preview_sources, :collection, item_type: :class, default: ["Alchemy::Admin::PreviewUrl"]
      end.new
    end

    it "sets the classes" do
      configuration.preview_sources = ["Alchemy::Admin::PreviewUrl", "Alchemy::Admin::PreviewUrl"]
      expect(configuration.preview_sources.to_a).to eq([Alchemy::Admin::PreviewUrl, Alchemy::Admin::PreviewUrl])
    end

    it "raises an error if the classes are not strings" do
      expect do
        configuration.preview_sources = [Alchemy::Admin::PreviewUrl, Alchemy::Admin::PreviewUrl]
      end.to raise_exception(
        Alchemy::Configuration::ConfigurationError,
        "Invalid configuration value for preview_sources: Alchemy::Admin::PreviewUrl (expected String)"
      )
    end
  end
end
