# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::PictureThumb::Create do
  let(:image) { File.new(File.expand_path("../../../fixtures/image.png", __dir__)) }
  let(:picture) { FactoryBot.create(:alchemy_picture, image_file: image) }
  let(:variant) { Alchemy::PictureVariant.new(picture, {size: "1x1"}) }

  subject(:create) do
    Alchemy::PictureThumb::Create.call(variant, "1234", "/pictures/#{picture.id}/1234/image.png")
  end

  it "creates thumb on picture thumbs collection" do
    expect { create }.to change { variant.picture.thumbs.reload.length }.by(1)
  end

  context "with a thumb already existing" do
    let!(:thumb) do
      Alchemy::PictureThumb.create!(
        picture: picture,
        signature: "1234",
        uid: "/pictures/#{picture.id}/1234/image.png"
      )
    end

    it "does not create a new thumb" do
      expect { create }.to_not change { picture.thumbs.reload.length }
    end
  end
end
