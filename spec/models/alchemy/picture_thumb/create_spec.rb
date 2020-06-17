# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::PictureThumb::Create do
  let(:image) { File.new(File.expand_path("../../../fixtures/image.png", __dir__)) }
  let(:picture) { FactoryBot.create(:alchemy_picture, image_file: image) }
  let(:variant) { Alchemy::PictureVariant.new(picture, { size: "1x1" }) }

  it "creates thumb on picture thumbs collection" do
    expect {
      Alchemy::PictureThumb::Create.call(variant, "1234", "/pictures/#{picture.id}/1234/image.png")
    }.to change { variant.picture.thumbs.length }.by(1)
  end
end
