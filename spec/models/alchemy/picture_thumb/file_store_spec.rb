# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::PictureThumb::FileStore do
  let(:image) { File.new(File.expand_path("../../../fixtures/image.png", __dir__)) }
  let(:picture) { FactoryBot.create(:alchemy_picture, image_file: image) }
  let!(:variant) { Alchemy::PictureVariant.new(picture, { size: "1x1" }) }
  let(:uid_path) { "pictures/#{picture.id}/1234" }

  let(:root_path) do
    datastore = Dragonfly.app(:alchemy_pictures).datastore
    datastore.server_root
  end

  subject(:store) do
    Alchemy::PictureThumb::FileStore.call(variant, "/#{uid_path}/image.png")
  end

  before do
    FileUtils.rm_rf("#{root_path}/#{uid_path}")
  end

  it "stores thumb on the disk" do
    expect { store }.to change { Dir.glob("#{root_path}/#{uid_path}").length }.by(1)
  end
end
