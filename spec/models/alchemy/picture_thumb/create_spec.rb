# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::PictureThumb::Create do
  let(:image) { File.new(File.expand_path("../../../fixtures/image.png", __dir__)) }
  let(:picture) { FactoryBot.create(:alchemy_picture, image_file: image) }
  let(:variant) { Alchemy::PictureVariant.new(picture, { size: "1x1" }) }

  subject(:create) do
    Alchemy::PictureThumb::Create.call(variant, "1234", "/pictures/#{picture.id}/1234/image.png")
  end

  it "creates thumb on picture thumbs collection" do
    expect { create }.to change { variant.picture.thumbs.reload.length }.by(1)
  end

  context "with an invalid picture" do
    let(:picture) { FactoryBot.build(:alchemy_picture) }

    before do
      expect(picture).to receive(:valid?) { false }
    end

    it "does not create a thumb" do
      expect { create }.not_to change { variant.picture.thumbs.reload.length }
    end

    it "does not process the image" do
      expect(variant).to_not receive(:image)
      create
    end
  end

  context "on processing errors" do
    before do
      variant
      expect(variant).to receive(:image) do
        raise(Dragonfly::Job::Fetch::NotFound)
      end
    end

    it "destroys thumbnail" do
      expect { subject }.to_not change { variant.picture.thumbs.reload.length }
    end
  end

  context "on file errors" do
    before do
      variant
      expect_any_instance_of(Dragonfly::Content).to receive(:to_file) do
        raise("Bam!")
      end
    end

    it "destroys thumbnail" do
      expect { subject }.to_not change { variant.picture.thumbs.reload.length }
    end
  end
end
