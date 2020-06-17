# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::PictureThumb::Uid do
  let(:image) { File.new(File.expand_path("../../../fixtures/image2.PNG", __dir__)) }
  let(:picture) { build_stubbed(:alchemy_picture, image_file: image) }
  let(:variant) { Alchemy::PictureVariant.new(picture) }

  subject { described_class.call("12345", variant) }

  it {
    is_expected.to eq "pictures/#{picture.id}/12345/image2.png"
  }

  context "with format options" do
    let(:variant) { Alchemy::PictureVariant.new(picture, { format: "jpg" }) }

    it "uses this as extension" do
      is_expected.to eq "pictures/#{picture.id}/12345/image2.jpg"
    end
  end

  context "with non word characters in filename" do
    let(:picture) { build_stubbed(:alchemy_picture, image_file: image, image_file_name: "The +*&image).png") }

    it "replaces them with underscore" do
      is_expected.to eq "pictures/#{picture.id}/12345/The_image_.png"
    end
  end

  context "with no image_file_name" do
    let(:picture) { build_stubbed(:alchemy_picture, image_file: image, image_file_name: nil) }

    it "uses 'image' as default" do
      is_expected.to eq "pictures/#{picture.id}/12345/image.png"
    end
  end
end
