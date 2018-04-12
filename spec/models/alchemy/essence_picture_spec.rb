# frozen_string_literal: true

require 'spec_helper'

module Alchemy
  describe EssencePicture do
    it_behaves_like "an essence" do
      let(:essence)          { EssencePicture.new }
      let(:ingredient_value) { Picture.new }
    end

    it_behaves_like "has image transformations" do
      let(:picture) { build_stubbed(:alchemy_essence_picture) }
    end

    it "should not store negative values for crop values" do
      essence = EssencePicture.new(crop_from: '-1x100', crop_size: '-20x30')
      essence.save!
      expect(essence.crop_from).to eq("0x100")
      expect(essence.crop_size).to eq("0x30")
    end

    it "should not store float values for crop values" do
      essence = EssencePicture.new(crop_from: '0.05x104.5', crop_size: '99.5x203.4')
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

    describe '#picture_url' do
      subject(:picture_url) { essence.picture_url(options) }

      let(:options) { {} }
      let(:picture) { create(:alchemy_picture) }
      let(:essence) { create(:alchemy_essence_picture, picture: picture) }

      context 'with no format in the options' do
        it "includes the image's default render format." do
          expect(picture_url).to match(/\.png/)
        end
      end

      context 'with format in the options' do
        let(:options) { {format: 'gif'} }

        it "takes this as format." do
          expect(picture_url).to match(/\.gif/)
        end
      end

      context 'when crop sizes are present' do
        before do
          expect(essence).to receive(:crop_size).and_return('200x200')
          expect(essence).to receive(:crop_from).and_return('10x10')
        end

        it "passes these crop sizes to the picture's url method." do
          expect(picture).to receive(:url).with(
            hash_including(crop_from: '10x10', crop_size: '200x200')
          )
          picture_url
        end

        context 'but with crop sizes in the options' do
          let(:options) do
            {crop_from: '30x30', crop_size: '75x75'}
          end

          it "passes these crop sizes instead." do
            expect(picture).to receive(:url).with(
              hash_including(crop_from: '30x30', crop_size: '75x75')
            )
            picture_url
          end
        end
      end

      context 'with other options' do
        let(:options) { {foo: 'baz'} }

        it 'adds them to the url' do
          expect(picture_url).to match /\?foo=baz/
        end
      end

      context 'without picture assigned' do
        let(:picture) { nil }

        it { is_expected.to be_nil }
      end
    end

    describe '#picture_url_options' do
      subject(:picture_url_options) { essence.picture_url_options }

      let(:picture) { build_stubbed(:alchemy_picture) }
      let(:essence) { build_stubbed(:alchemy_essence_picture, picture: picture) }

      it { is_expected.to be_a(HashWithIndifferentAccess) }

      it "includes the pictures default render format." do
        expect(picture).to receive(:default_render_format) { 'img' }
        expect(picture_url_options[:format]).to eq('img')
      end

      context 'with crop sizes present' do
        before do
          expect(essence).to receive(:crop_size) { '200x200' }
          expect(essence).to receive(:crop_from) { '10x10' }
        end

        it "includes these crop sizes.", :aggregate_failures do
          expect(picture_url_options[:crop_from]).to eq '10x10'
          expect(picture_url_options[:crop_size]).to eq '200x200'
        end
      end

      # Regression spec for issue #1279
      context 'with crop sizes being empty strings' do
        before do
          expect(essence).to receive(:crop_size) { '' }
          expect(essence).to receive(:crop_from) { '' }
        end

        it "does not include these crop sizes.", :aggregate_failures do
          expect(picture_url_options[:crop_from]).to be_nil
          expect(picture_url_options[:crop_size]).to be_nil
        end
      end

      context 'without picture assigned' do
        let(:picture) { nil }

        it { is_expected.to be_a(Hash) }
      end
    end

    describe '#thumbnail_url' do
      subject(:thumbnail_url) { essence.thumbnail_url(options) }

      let(:options) { {} }

      let(:picture) do
        build_stubbed(:alchemy_picture)
      end

      let(:essence) do
        build_stubbed(:alchemy_essence_picture, picture: picture)
      end

      let(:content) do
        build_stubbed(:alchemy_content, essence: essence)
      end

      before do
        allow(essence).to receive(:content) { content }
      end

      it "includes the image's original file format." do
        expect(thumbnail_url).to match(/\.png/)
      end

      it "flattens the image." do
        expect(picture).to receive(:url).with(hash_including(flatten: true))
        thumbnail_url
      end

      context 'when crop sizes are present' do
        before do
          allow(essence).to receive(:crop_size).and_return('200x200')
          allow(essence).to receive(:crop_from).and_return('10x10')
        end

        it "passes these crop sizes to the picture's url method." do
          expect(picture).to receive(:url).with(
            hash_including(crop_from: '10x10', crop_size: '200x200', crop: true)
          )
          thumbnail_url
        end
      end

      context 'when no crop sizes are present' do
        it "it does not pass crop sizes to the picture's url method and disables cropping." do
          expect(picture).to receive(:url).with(
            hash_including(crop_from: nil, crop_size: nil, crop: false)
          )
          thumbnail_url
        end

        context 'when crop is explicitely enabled in the options' do
          let(:options) do
            {crop: true}
          end

          it "it enables cropping." do
            expect(picture).to receive(:url).with(
              hash_including(crop: true)
            )
            thumbnail_url
          end
        end
      end

      context 'with other options' do
        let(:options) { {foo: 'baz'} }

        it 'drops them' do
          expect(thumbnail_url).to_not match /\?foo=baz/
        end
      end

      context 'without picture assigned' do
        let(:picture) { nil }

        it { is_expected.to be_nil }
      end
    end

    describe '#cropping_mask' do
      subject { essence.cropping_mask }

      context 'with crop values given' do
        let(:essence) { build_stubbed(:alchemy_essence_picture, crop_from: '0x0', crop_size: '100x100') }

        it "returns a hash containing cropping coordinates" do
          is_expected.to eq({x1: 0, y1: 0, x2: 100, y2: 100})
        end
      end

      context 'with no crop values given' do
        let(:essence) { build_stubbed(:alchemy_essence_picture) }

        it { is_expected.to be_nil }
      end
    end

    describe '#preview_text' do
      let(:picture) { mock_model(Picture, name: 'Cute Cat Kittens') }
      let(:essence) { EssencePicture.new }

      it "should return the pictures name as preview text" do
        allow(essence).to receive(:picture).and_return(picture)
        expect(essence.preview_text).to eq('Cute Cat Kittens')
      end

      context "with no picture assigned" do
        it "returns empty string" do
          expect(essence.preview_text).to eq('')
        end
      end
    end

    describe '#serialized_ingredient' do
      let(:content) do
        Content.new
      end

      let(:picture) do
        mock_model Picture,
          name: 'Cute Cat Kittens',
          urlname: 'cute-cat-kittens',
          security_token: 'kljhgfd',
          default_render_format: 'jpg'
      end

      let(:essence) do
        EssencePicture.new(content: content, picture: picture)
      end

      it "returns the url to render the picture" do
        expect(essence).to receive(:picture_url).with(content.settings)
        essence.serialized_ingredient
      end

      context 'with image settings set as content settings' do
        let(:settings) do
          {
            size: '150x150',
            format: 'png'
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
              allow(picture).to receive(:can_be_cropped_to) { true }
            end

            it { is_expected.to be_falsy }

            context "with crop set to true" do
              before do
                allow(content).to receive(:settings_value) { true }
              end

              it { is_expected.to be(true) }
            end
          end
        end
      end
    end
  end
end
