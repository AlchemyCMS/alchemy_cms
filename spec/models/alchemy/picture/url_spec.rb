# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Picture::Url do
  let(:image) { File.new(File.expand_path("../../../fixtures/image.png", __dir__)) }
  let(:picture) { create(:alchemy_picture, image_file: image) }

  subject { described_class.new(picture).call(options) }

  let(:options) { {} }

  it "returns the proxy url to the image" do
    is_expected.to match(/\/rails\/active_storage\/representations\/proxy\/.+\/image\.png/)
  end

  it "adds image name and format to url" do
    is_expected.to match(/\/image\.png$/)
  end

  context "with a processed variant" do
    let(:options) do
      { size: "10x10" }
    end

    it "uses converted options for image_processing" do
      expect(picture.image_file).to receive(:variant).with(
        {
          resize_to_limit: [10, 10, { sharpen: false }],
          saver: { quality: 85 },
        },
      )
      subject
    end
  end

  context "with format in options" do
    let(:options) do
      { format: "webp" }
    end

    it "adds format to url" do
      is_expected.to match(/\/image\.webp$/)
    end
  end
end
