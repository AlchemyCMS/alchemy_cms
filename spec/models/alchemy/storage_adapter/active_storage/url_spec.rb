require "rails_helper"

RSpec.describe Alchemy::StorageAdapter::ActiveStorage::Url do
  let(:picture) { create(:alchemy_picture) }
  let(:image_file) { picture.image_file }
  let(:variant) { double("variant") }

  before do
    allow(Alchemy.config).to receive(:image_output_format) { "webp" }
    allow(image_file).to receive(:variant).and_return(variant)
    allow(Rails.application.routes.url_helpers).to receive(:rails_blob_path) do
      "/rails/active_storage/blobs/variant.png"
    end
  end

  subject { described_class.new(picture) }

  describe "#call" do
    it "returns the url for the variant" do
      url = subject.call(size: "100x100")
      expect(url).to eq("/rails/active_storage/blobs/variant.png")
      expect(image_file).to have_received(:variant).with(
        hash_including(resize_to_limit: [100, 100, {sharpen: false}])
      )
    end

    it "uses the provided format if given" do
      subject.call(size: "100x100", format: "jpg")
      expect(image_file).to have_received(:variant).with(hash_including(format: "jpg"))
    end

    it "returns nil if image_file is nil" do
      allow(picture).to receive(:image_file).and_return(nil)
      expect(subject.call).to be_nil
    end

    it "returns nil if variant is nil" do
      allow(image_file).to receive(:variant).and_return(nil)
      expect(subject.call(size: "100x100")).to be_nil
    end
  end

  describe "#filename" do
    it "returns the picture name if present" do
      allow(picture).to receive(:name).and_return(double(to_param: "pretty-name"))
      subject.call
      expect(Rails.application.routes.url_helpers).to have_received(:rails_blob_path).with(
        variant, hash_including(filename: "pretty-name")
      )
    end

    it "returns the image_file_name if name is blank" do
      allow(picture).to receive(:name).and_return(nil)
      allow(picture).to receive(:image_file_name).and_return("pretty-image-name")
      subject.call
      expect(Rails.application.routes.url_helpers).to have_received(:rails_blob_path).with(
        variant, hash_including(filename: "pretty-image-name")
      )
    end
  end

  describe "#default_output_format" do
    it "returns the configured format if not 'original'" do
      subject.call
      expect(Rails.application.routes.url_helpers).to have_received(:rails_blob_path).with(
        variant, hash_including(format: "webp")
      )
    end

    it "returns the image_file_extension if config is 'original'" do
      allow(Alchemy.config).to receive(:image_output_format).and_return("original")
      allow(picture).to receive(:image_file_extension).and_return("gif")
      subject.call
      expect(Rails.application.routes.url_helpers).to have_received(:rails_blob_path).with(
        variant, hash_including(format: "gif")
      )
    end
  end
end
