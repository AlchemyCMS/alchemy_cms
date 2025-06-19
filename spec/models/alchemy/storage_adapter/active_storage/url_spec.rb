require "rails_helper"

RSpec.describe Alchemy::StorageAdapter::ActiveStorage::Url, if: Alchemy.storage_adapter.active_storage? do
  let(:picture) { create(:alchemy_picture) }
  let(:image_file) { picture.image_file }

  before do
    allow(Alchemy.config).to receive(:image_output_format) { "webp" }
  end

  subject(:url) { described_class.new(picture).call(**options) }

  let(:options) { {} }

  it "returns the url for the variant" do
    expect(url).to match(/\/rails\/active_storage\/representations\/redirect\/.+\/image\.webp/)
  end

  it "returns the configured format if not 'original'" do
    expect(url).to match(/\.webp/)
  end

  it "returns nil if image_file is nil" do
    allow(picture).to receive(:image_file).and_return(nil)
    expect(url).to be_nil
  end

  it "returns nil if variant is nil" do
    allow(image_file).to receive(:variant).and_return(nil)
    expect(url).to be_nil
  end

  it "returns the image_file_extension if config is 'original'" do
    allow(Alchemy.config).to receive(:image_output_format).and_return("original")
    allow(picture).to receive(:image_file_extension).and_return("gif")
    expect(url).to match(/\.gif/)
  end

  context "with format given" do
    let(:options) { {format: "jpg"} }

    it "uses the provided format" do
      expect(url).to match(/\/rails\/active_storage\/representations\/redirect\/.+\/image\.jpg/)
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
