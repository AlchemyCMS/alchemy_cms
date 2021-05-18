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

    it "should not store negative values for crop values" do
      essence = EssencePicture.new(crop_from: "-1x100", crop_size: "-20x30")
      essence.save!
      expect(essence.crop_from).to eq("0x100")
      expect(essence.crop_size).to eq("0x30")
    end

    it "should not store float values for crop values" do
      essence = EssencePicture.new(crop_from: "0.05x104.5", crop_size: "99.5x203.4")
      essence.save!
      expect(essence.crop_from).to eq("0x105")
      expect(essence.crop_size).to eq("100x203")
    end

    it "should not store empty strings for nil crop values" do
      essence = EssencePicture.new(crop_from: nil, crop_size: nil)
      essence.save!
      expect(essence.crop_from).to eq(nil)
      expect(essence.crop_size).to eq(nil)
    end

    it "should convert newlines in caption into <br/>s" do
      essence = EssencePicture.new(caption: "hello\nkitty")
      essence.save!
      expect(essence.caption).to eq("hello<br/>kitty")
    end

    describe "#picture_url" do
      subject(:picture_url) { essence.picture_url(options) }

      let(:options) { {} }
      let(:picture) { create(:alchemy_picture) }
      let(:essence) { create(:alchemy_essence_picture, :with_content, picture: picture) }

      context "with no format in the options" do
        it "includes the image's default render format." do
          expect(picture_url).to match(/\.png/)
        end
      end

      context "with format in the options" do
        let(:options) { { format: "gif" } }

        it "takes this as format." do
          expect(picture_url).to match(/\.gif/)
        end
      end

      context "when crop sizes are present" do
        let(:essence) do
          create(:alchemy_essence_picture, :with_content, picture: picture, crop_size: "200x200", crop_from: "10x10")
        end

        it "passes these crop sizes to the picture's url method." do
          expect(picture).to receive(:url).with(
            hash_including(crop_from: "10x10", crop_size: "200x200"),
          )
          picture_url
        end

        context "but with crop sizes in the options" do
          let(:options) do
            { crop_from: "30x30", crop_size: "75x75" }
          end

          it "passes these crop sizes instead." do
            expect(picture).to receive(:url).with(
              hash_including(crop_from: "30x30", crop_size: "75x75"),
            )
            picture_url
          end
        end
      end

      context "with other options" do
        let(:options) { { foo: "baz" } }

        it "adds them to the url" do
          expect(picture_url).to match /\?foo=baz/
        end
      end

      context "without picture assigned" do
        let(:picture) { nil }

        it { is_expected.to be_nil }
      end

      context "if picture.url returns nil" do
        before do
          expect(picture).to receive(:url) { nil }
        end

        it "returns missing image url" do
          is_expected.to eq "missing-image.png"
        end
      end
    end

    describe "#picture_url_options" do
      subject(:picture_url_options) { essence.picture_url_options }

      let(:picture) { build_stubbed(:alchemy_picture) }
      let(:essence) { build_stubbed(:alchemy_essence_picture, :with_content, picture: picture) }

      it { is_expected.to be_a(HashWithIndifferentAccess) }

      it "includes the pictures default render format." do
        expect(picture).to receive(:default_render_format) { "img" }
        expect(picture_url_options[:format]).to eq("img")
      end

      context "with crop sizes present" do
        let(:essence) do
          create(:alchemy_essence_picture, :with_content, picture: picture, crop_size: "200x200", crop_from: "10x10")
        end

        it "includes these crop sizes.", :aggregate_failures do
          expect(picture_url_options[:crop_from]).to eq "10x10"
          expect(picture_url_options[:crop_size]).to eq "200x200"
        end

        it "includes {crop: true}" do
          expect(picture_url_options[:crop]).to be true
        end
      end

      # Regression spec for issue #1279
      context "with crop sizes being empty strings" do
        let(:essence) do
          create(:alchemy_essence_picture, :with_content, picture: picture, crop_size: "", crop_from: "")
        end

        it "does not include these crop sizes.", :aggregate_failures do
          expect(picture_url_options[:crop_from]).to be_nil
          expect(picture_url_options[:crop_size]).to be_nil
        end

        it "includes {crop: false}" do
          expect(picture_url_options[:crop]).to be false
        end
      end

      context "with content having size setting" do
        before do
          expect(essence.content).to receive(:settings).twice { { size: "30x70" } }
        end

        it "includes this size." do
          expect(picture_url_options[:size]).to eq "30x70"
        end
      end

      context "with content having crop setting" do
        before do
          expect(essence.content).to receive(:settings).twice { { crop: true } }
        end

        it "includes this setting" do
          expect(picture_url_options[:crop]).to be true
        end
      end

      context "without picture assigned" do
        let(:picture) { nil }

        it { is_expected.to be_a(Hash) }
      end
    end

    describe "#thumbnail_url" do
      subject(:thumbnail_url) { essence.thumbnail_url }

      let(:settings) do
        {}
      end

      let(:picture) do
        create(:alchemy_picture)
      end

      let(:essence) do
        create(:alchemy_essence_picture, picture: picture)
      end

      let(:content) do
        create(:alchemy_content, essence: essence)
      end

      before do
        allow(content).to receive(:settings) { settings }
      end

      it "includes the image's original file format." do
        expect(thumbnail_url).to match(/\.png/)
      end

      it "flattens the image." do
        expect(picture).to receive(:url).with(hash_including(flatten: true))
        thumbnail_url
      end

      context "when crop sizes are present" do
        before do
          allow(essence).to receive(:crop_size).and_return("200x200")
          allow(essence).to receive(:crop_from).and_return("10x10")
        end

        it "passes these crop sizes to the picture's url method." do
          expect(picture).to receive(:url).with(
            hash_including(crop_from: "10x10", crop_size: "200x200", crop: true),
          )
          thumbnail_url
        end
      end

      context "when no crop sizes are present" do
        it "it does not pass crop sizes to the picture's url method and disables cropping." do
          expect(picture).to receive(:url).with(
            hash_including(crop_from: nil, crop_size: nil, crop: false),
          )
          thumbnail_url
        end

        context "when crop is explicitely enabled in the settings" do
          let(:settings) do
            { crop: true }
          end

          it "it enables cropping." do
            expect(picture).to receive(:url).with(
              hash_including(crop: true),
            )
            thumbnail_url
          end
        end
      end

      context "without picture assigned" do
        let(:picture) { nil }

        it { is_expected.to be_nil }
      end

      context "if picture.url returns nil" do
        before do
          expect(picture).to receive(:url) { nil }
        end

        it "returns missing image url" do
          is_expected.to eq "alchemy/missing-image.svg"
        end
      end
    end

    describe "#thumbnail_url_options" do
      subject(:thumbnail_url_options) { essence.thumbnail_url_options }

      let(:settings) { {} }
      let(:picture) { nil }

      let(:essence) do
        build_stubbed(:alchemy_essence_picture, picture: picture)
      end

      let(:content) do
        build_stubbed(:alchemy_content, essence: essence)
      end

      before do
        allow(content).to receive(:settings) { settings }
      end

      context "with picture assigned" do
        let(:picture) do
          create(:alchemy_picture)
        end

        it "includes the image's original file format." do
          expect(thumbnail_url_options[:format]).to eq("png")
        end

        it "flattens the image." do
          expect(thumbnail_url_options[:flatten]).to be(true)
        end
      end

      context "when crop values are present" do
        before do
          expect(essence).to receive(:crop_size).at_least(:once) { "200x200" }
          expect(essence).to receive(:crop_from).at_least(:once) { "10x10" }
        end

        it "includes these crop values" do
          expect(thumbnail_url_options).to match(
            hash_including(crop_from: "10x10", crop_size: "200x200", crop: true)
          )
        end
      end

      context "when no crop values are present" do
        it "does not include these crop values" do
          expect(thumbnail_url_options).to_not match(
            hash_including(crop_from: "10x10", crop_size: "200x200", crop: true)
          )
        end

        context "when crop is explicitely enabled in the settings" do
          let(:settings) do
            { crop: true }
          end

          it "it enables cropping." do
            expect(thumbnail_url_options).to match(
              hash_including(crop: true),
            )
          end
        end
      end

      context "without picture assigned" do
        let(:picture) { nil }

        it "returns default thumbnail options" do
          is_expected.to eq(
            crop: false,
            crop_from: nil,
            crop_size: nil,
            flatten: true,
            format: "jpg",
            size: "160x120",
          )
        end
      end
    end

    describe "#image_cropper_settings" do
      let(:content) { essence.content }
      let(:essence) { build_stubbed(:alchemy_essence_picture, :with_content, picture: picture) }
      let(:picture) { nil }

      subject { essence.image_cropper_settings }

      context "with no picture assigned" do
        it { is_expected.to eq({}) }
      end

      context "with picture assigned" do
        let(:picture) { build_stubbed(:alchemy_picture) }

        let(:default_mask) do
          [
            0,
            0,
            300,
            250,
          ]
        end

        let(:settings) { {} }

        before do
          picture.image_file_width = 300
          picture.image_file_height = 250
          allow(content).to receive(:settings) { settings }
        end

        context "with no render_size present in essence" do
          before do
            expect(essence).to receive(:render_size).at_least(:once).and_return(nil)
          end

          context "with sizes in content settings" do
            let(:settings) do
              { size: "300x250" }
            end

            it "sets sizes to given values" do
              expect(subject[:min_size]).to eq([300, 250])
            end
          end

          context "with no sizes in content settngs" do
            it "sets sizes to zero" do
              expect(subject[:min_size]).to eq([0, 0])
            end
          end
        end

        context "with render_size present in essence" do
          it "sets sizes from these values" do
            expect(essence).to receive(:render_size).at_least(:once).and_return("30x25")
            expect(subject[:min_size]).to eq([30, 25])
          end

          context "when width or height is not fixed" do
            it "infers the height from the image file preserving the aspect ratio" do
              expect(essence).to receive(:render_size).at_least(:once).and_return("30x")
              expect(subject[:min_size]).to eq([30, 0])
            end

            context "and aspect ratio set on the contents settings" do
              let(:settings) do
                { fixed_ratio: "2" }
              end

              it "does not infer the height from the image file preserving the aspect ratio" do
                expect(essence).to receive(:render_size).at_least(:once).and_return("x25")
                expect(subject[:min_size]).to eq([50, 25])
              end
            end
          end

          context "when width or height is not fixed and an aspect ratio is given" do
            context "and aspect ratio set on the contents setting" do
              let(:settings) do
                { fixed_ratio: "0.5" }
              end

              it "width is given, it infers the height from width and ratio" do
                expect(essence).to receive(:render_size).at_least(:once).and_return("30x")
                expect(subject[:min_size]).to eq([30, 60])
              end
            end

            it "infers the height from the image file preserving the aspect ratio" do
              expect(essence).to receive(:render_size).at_least(:once).and_return("x25")
              expect(subject[:min_size]).to eq([0, 25])
            end
          end
        end

        context "no crop sizes present in essence" do
          it "assigns default mask boxes" do
            expect(subject[:default_box]).to eq(default_mask)
          end
        end

        context "crop sizes present in essence" do
          let(:mask) { [0, 0, 120, 160] }

          before do
            allow(essence).to receive(:crop_from).and_return("0x0")
            allow(essence).to receive(:crop_size).and_return("120x160")
          end

          it "assigns cropping boxes" do
            expect(subject[:default_box]).to eq(default_mask)
          end
        end

        context "with fixed_ratio set to false" do
          let(:settings) do
            { fixed_ratio: false }
          end

          it "sets ratio to false" do
            expect(subject[:ratio]).to eq(false)
          end
        end

        context "with fixed_ratio set to a non float string" do
          let(:settings) do
            { fixed_ratio: "123,45" }
          end

          it "raises an error" do
            expect { subject }.to raise_exception(ArgumentError)
          end
        end

        context "with no fixed_ratio set" do
          let(:settings) do
            { size: "80x60" }
          end

          it "sets a fixed ratio from sizes" do
            expect(subject[:ratio]).to eq(80.0 / 60.0)
          end
        end
      end
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

    describe "#allow_image_cropping?" do
      let(:essence_picture) { stub_model(Alchemy::EssencePicture) }
      let(:content) { stub_model(Alchemy::Content) }
      let(:picture) { stub_model(Alchemy::Picture) }

      subject { essence_picture.allow_image_cropping? }

      it { is_expected.to be_falsy }

      context "with content existing?" do
        before do
          allow(essence_picture).to receive(:content) { content }
        end

        it { is_expected.to be_falsy }

        context "with picture assigned" do
          before do
            allow(essence_picture).to receive(:picture) { picture }
          end

          it { is_expected.to be_falsy }

          context "and with image larger than crop size" do
            before do
              allow(picture).to receive(:can_be_cropped_to?) { true }
            end

            it { is_expected.to be_falsy }

            context "with crop set to true" do
              before do
                allow(content).to receive(:settings) { { crop: true } }
              end

              context "if picture.image_file is nil" do
                before do
                  expect(picture).to receive(:image_file) { nil }
                end

                it { is_expected.to be_falsy }
              end

              context "if picture.image_file is present" do
                let(:picture) { build_stubbed(:alchemy_picture) }

                it { is_expected.to be(true) }
              end
            end
          end
        end
      end
    end
  end
end
