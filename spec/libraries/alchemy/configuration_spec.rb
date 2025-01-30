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

  context "without a default value" do
    let(:configuration) do
      Class.new(described_class) do
        option :auto_logout_time, :integer
      end.new
    end

    it "defaults to nil" do
      expect(configuration.auto_logout_time).to be nil
    end
  end

  context "setting with the wrong type" do
    it "raises an error" do
      expect do
        configuration.auto_logout_time = "14"
      end.to raise_exception(TypeError, 'auto_logout_time must be set as a Integer, given "14"')
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
      end.to raise_exception(TypeError, "picture_thumb_storage_class must be set as a String, given String")
    end
  end

  describe "setting and changing class sets" do
    let(:configuration) do
      Class.new(described_class) do
        option :preview_sources, :class_set, default: ["Alchemy::Admin::PreviewUrl"]
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
      end.to raise_exception(TypeError, "cache_pages must be a Boolean, given \"true\"")
    end
  end

  describe "integer lists" do
    let(:configuration) do
      Class.new(described_class) do
        option :page_preview_sizes, :integer_list, default: [1, 2]
      end.new
    end

    it "returns the integer list" do
      expect(configuration.page_preview_sizes).to eq([1, 2])
    end

    it "can only be set with an integer list" do
      expect do
        configuration.page_preview_sizes = ["1"]
      end.to raise_exception(TypeError, 'page_preview_sizes must be an Array of integers, given ["1"]')
    end
  end

  describe "string lists" do
    let(:configuration) do
      Class.new(described_class) do
        option :link_target_options, :string_list, default: ["blank"]
      end.new
    end

    it "returns the string list" do
      expect(configuration.link_target_options).to eq(["blank"])
    end

    it "can only be set with an Array of strings" do
      expect do
        configuration.link_target_options = [:blank]
      end.to raise_exception(TypeError, "link_target_options must be an Array of strings, given [:blank]")
    end
  end
end
