require "rails_helper"

RSpec.describe Alchemy::StorageAdapter::ActiveStorage::PictureUrl, if: Alchemy.storage_adapter.active_storage? do
  let(:picture) { create(:alchemy_picture, image_file:) }
  let(:image_file) { fixture_file_upload("image.png") }

  before do
    allow(Alchemy.config).to receive(:image_output_format) { "webp" }
  end

  subject(:url) { described_class.new(picture).call(**options) }

  let(:options) { {} }

  context "when picture has no image_file" do
    before do
      allow(picture).to receive(:image_file).and_return(nil)
    end

    it "returns nil" do
      expect(url).to be_nil
    end
  end

  context "with variable image file" do
    it "returns the url for the variant" do
      expect(url).to match(/\/rails\/active_storage\/representations\/redirect\/.+\/image\.webp/)
    end

    it "returns the configured format if not 'original'" do
      expect(url).to match(/\.webp/)
    end

    context "if config is 'original'" do
      before do
        allow(Alchemy.config).to receive(:image_output_format).and_return("original")
      end

      it "returns the image_file_extension" do
        expect(url).to match(/\.png/)
      end
    end

    context "with format given" do
      let(:options) { {format: "jpg"} }

      it "uses the provided format" do
        expect(url).to match(/\/rails\/active_storage\/representations\/redirect\/.+\/image\.jpg/)
      end
    end
  end

  context "with invariable image file" do
    let(:picture) { create(:alchemy_picture, image_file:) }
    let(:image_file) { fixture_file_upload("icon.svg") }

    it "returns the url for the original image" do
      expect(url).to match(/\/rails\/active_storage\/blobs\/redirect\/.+\/image\.svg/)
    end

    it "returns the image_file_extension" do
      expect(url).to match(/\.svg/)
    end
  end

  it "uses the picture name if present" do
    allow(picture).to receive(:name).and_return(double(to_param: "pretty-name"))
    expect(url).to match(/pretty-name/)
  end

  it "uses the image_file_name if name is blank" do
    allow(picture).to receive(:name).and_return(nil)
    allow(picture).to receive(:image_file_name).and_return("pretty-image-name")
    expect(url).to match(/pretty-image-name/)
  end
end
