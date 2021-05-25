# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe EssencePicture do
    around do |example|
      RSpec.configure do |config|
        config.mock_with :rspec do |mock|
          mock.verify_partial_doubles = true
        end
      end
      example.run
      RSpec.configure do |config|
        config.mock_with :rspec do |mock|
          mock.verify_partial_doubles = false
        end
      end
    end

    it_behaves_like "an essence" do
      let(:essence) { EssencePicture.new }
      let(:ingredient_value) { Picture.new }
    end

    describe "eager loading" do
      let!(:essence_pictures) { create_list(:alchemy_essence_picture, 2) }

      it "eager loads pictures" do
        essences = described_class.all.includes(:ingredient_association)
        expect(essences[0].association(:ingredient_association)).to be_loaded
      end
    end

    it_behaves_like "having picture thumbnails" do
      let(:picture) { build(:alchemy_picture) }
      let(:record) { build(:alchemy_essence_picture, :with_content, picture: picture) }
    end

    it "should convert newlines in caption into <br/>s" do
      essence = EssencePicture.new(caption: "hello\nkitty")
      essence.save!
      expect(essence.caption).to eq("hello<br/>kitty")
    end

    describe "#preview_text" do
      let(:picture) { mock_model(Picture, name: "Cute Cat Kittens") }
      let(:essence) { EssencePicture.new }

      it "should return the pictures name as preview text" do
        allow(essence).to receive(:picture).and_return(picture)
        expect(essence.preview_text).to eq("Cute Cat Kittens")
      end

      context "with no picture assigned" do
        it "returns empty string" do
          expect(essence.preview_text).to eq("")
        end
      end
    end

    describe "#serialized_ingredient" do
      let(:content) do
        Content.new
      end

      let(:picture) do
        mock_model Picture,
          name: "Cute Cat Kittens",
          urlname: "cute-cat-kittens",
          security_token: "kljhgfd",
          default_render_format: "jpg"
      end

      let(:essence) do
        EssencePicture.new(content: content, picture: picture)
      end

      it "returns the url to render the picture" do
        expect(essence).to receive(:picture_url).with(content.settings)
        essence.serialized_ingredient
      end

      context "with image settings set as content settings" do
        let(:settings) do
          {
            size: "150x150",
            format: "png",
          }
        end

        before do
          expect(content).to receive(:settings) { settings }
        end

        it "returns the url with cropping and resizing options" do
          expect(essence).to receive(:picture_url).with(settings)
          essence.serialized_ingredient
        end
      end
    end
  end
end
