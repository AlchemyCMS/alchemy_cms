require 'spec_helper'

describe "Picture url helpers" do
  describe "for cropped picture" do
    let(:path) do
      show_picture_path(id: 3, crop: "crop", size: "100x33", name: "kitten", format: "jpg")
    end

    it "should generate a url string" do
      expect(path).to eq("/pictures/3/show/100x33/crop/kitten.jpg")
    end
  end

  describe "for cropped and masked picture" do
    let(:path) do
      show_picture_path(
        id: 3,
        crop: "crop",
        crop_from: "0x0",
        crop_size: "900x300",
        size: "100x33",
        name: "kitten",
        format: :jpg
      )
    end

    it "should generate a url string" do
      expect(path).to eq("/pictures/3/show/100x33/crop/0x0/900x300/kitten.jpg")
    end
  end

  describe "for cropped thumbnail" do
    let(:path) do
      thumbnail_path(id: 3, crop: "crop", size: "100x33", name: "kitten", format: :jpg)
    end

    it "should generate a url string" do
      expect(path).to eq("/pictures/3/thumbnails/100x33/crop/kitten.jpg")
    end
  end

  describe "for thumbnail with default name and format" do
    let(:path) do
      thumbnail_path(id: 3, size: "100x33")
    end

    it "should generate a url string" do
      expect(path).to eq("/pictures/3/thumbnails/100x33/thumbnail.png")
    end
  end

  describe "for cropped and masked thumbnail" do
    let(:path) do
      thumbnail_path(
        id: 3,
        crop_from: "0x0",
        crop_size: "900x300",
        size: "100x33",
        name: "kitten",
        format: :jpg
      )
    end

    it "should generate a url string" do
      expect(path).to eq("/pictures/3/thumbnails/100x33/0x0/900x300/kitten.jpg")
    end
  end

  describe "for zoomed image" do
    let(:path) do
      zoom_picture_path(id: 3, name: "kitten", format: :jpg)
    end

    it "should generate a url string" do
      expect(path).to eq("/pictures/3/zoom/kitten.jpg")
    end
  end
end
