# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Picture::Url do
  let(:image) { File.new(File.expand_path("../../../fixtures/image.png", __dir__)) }
  let(:picture) { create(:alchemy_picture, image_file: image) }
  let(:variant) { Alchemy::PictureVariant.new(picture) }

  subject { described_class.new(variant).call(params) }

  let(:params) { {} }

  it "returns the url to the image" do
    is_expected.to match(/\/pictures\/.+\/image\.png\?sha=.+/)
  end

  context "when params are passed" do
    let(:params) do
      {
        page: 1,
        per_page: 10,
      }
    end

    it "passes them to the URL" do
      is_expected.to match(/page=1/)
    end
  end

  context "with a processed variant" do
    let(:variant) { Alchemy::PictureVariant.new(picture, { size: "10x10" }) }

    it "returns the url to the thumbnail" do
      is_expected.to match(/\/pictures\/\d+\/.+\/image\.png/)
    end
  end
end
