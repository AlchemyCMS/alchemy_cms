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

    it "should convert newlines in caption into <br/>s" do
      essence = EssencePicture.new(caption: "hello\nkitty")
      essence.save!
      expect(essence.caption).to eq("hello<br/>kitty")
    end

    describe '#picture_url' do
      subject { essence.picture_url(options) }

      let(:options) { {} }
      let(:picture) { build_stubbed(:alchemy_picture) }
      let(:essence) { build_stubbed(:alchemy_essence_picture, picture: picture) }

      it "includes the secure hash." do
        is_expected.to match(/\?sh=\S+\z/)
      end

      context 'with size in the options' do
        let(:options) { {size: '200x300'} }

        it "includes the size in the url." do
          is_expected.to match(/200x300/)
        end
      end

      context 'with no format in the options' do
        it "includes the image's default render format." do
          is_expected.to match(/#{picture.default_render_format}/)
        end
      end

      context 'with format in the options' do
        let(:options) { {format: 'png'} }

        it "takes this as format." do
          is_expected.to match(/png/)
        end
      end

      context 'when cropping is allowed' do
        let(:options) { {crop: true} }

        it 'converts the value `true` of the `crop` option into `crop` as part of the url' do
          is_expected.to match /crop/
          is_expected.not_to match /true/
        end

        context 'and crop sizes are set' do
          before do
            expect(essence).to receive(:crop_size).at_least(:once).and_return('200x200')
            expect(essence).to receive(:crop_from).at_least(:once).and_return('10x10')
          end

          it "includes the crop sizes in the url." do
            is_expected.to match(/200x200/)
            is_expected.to match(/10x10/)
          end

          context 'but with crop sizes in the options' do
            before do
              options.update({crop_from: '30x30', crop_size: '75x75'})
            end

            it "includes these crop sizes instead." do
              is_expected.to match(/30x30/)
              is_expected.to match(/75x75/)
            end
          end
        end
      end

      context 'when cropping is prohibited' do
        before do
          expect(essence).not_to receive(:crop_size)
          expect(essence).not_to receive(:crop_from)
        end

        context 'without setting `crop` in the options' do
          it "does not include `crop` in the url" do
            is_expected.not_to match(/crop/)
          end
        end

        context 'when `crop` is explicitly set to `false`' do
          let(:options) { {crop: false} }

          it "does not include `crop` in the url" do
            is_expected.not_to match(/crop/)
          end
        end

        context 'even when crop sizes are set' do
          it "does not include any cropping information in the url" do
            is_expected.not_to match(/crop/)
            is_expected.not_to match(/200x200/)
            is_expected.not_to match(/10x10/)
          end
        end
      end

      context 'with `image_size` in the options' do
        let(:options) { {image_size: '100x100'} }

        it 'converts the key into `size`' do
          is_expected.to match /100x100/
        end
      end

      context 'with other options' do
        let(:options) { {foo: 'baz'} }

        it 'it removes them from params' do
          is_expected.not_to match /foo/
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
        expect(essence.serialized_ingredient).to eq("/pictures/#{picture.id}/show/#{picture.urlname}.jpg?sh=#{picture.security_token}")
      end

      context 'with image settings given at content' do
        before do
          expect(content).to receive(:settings).and_return({size: '150x150', format: 'png', select_values: [1, 2, 3]})
        end

        it "returns the url with cropping and resizing options" do
          expect(essence.serialized_ingredient).to eq("/pictures/#{picture.id}/show/150x150/#{picture.urlname}.png?sh=#{picture.security_token}")
        end

        it "rejects options that are not cropping and resizing options" do
          expect(essence.serialized_ingredient).to_not match("select_values")
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
