require 'spec_helper'

module Alchemy
  describe PictureStyle do
    describe '#picture_url' do
      subject { picture_style.url(options) }

      let(:options) { {} }
      let(:picture) { create(:picture) }
      let(:essence) { create(:essence_picture, picture: picture) }
      let(:picture_style) { essence.picture_style }

      it "returns the show picture url." do
        is_expected.to match(/\/pictures\/#{picture.id}\/show\/#{picture.urlname}\.#{Config.get(:image_output_format)}/)
      end

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
        it "includes the default image output format." do
          is_expected.to match(/#{Config.get(:image_output_format)}/)
        end
      end

      context 'with format in the options' do
        let(:options) { {format: 'png'} }

        it "takes this as format." do
          is_expected.to match(/png/)
        end
      end

      context 'with crop sizes set' do
        before do
          expect(picture_style).to receive(:crop_size).at_least(:once).and_return('200x200')
          expect(picture_style).to receive(:crop_from).at_least(:once).and_return('10x10')
        end

        it "includes the crop sizes in the url." do
          is_expected.to match(/200x200/)
          is_expected.to match(/10x10/)
        end

        context 'but with crop sizes in the options' do
          let(:options) { {crop_from: '30x30', crop_size: '75x75'} }

          it "includes these crop sizes instead." do
            is_expected.to match(/30x30/)
            is_expected.to match(/75x75/)
          end
        end
      end

      context 'with crop true in the options' do
        let(:options) { {crop: true} }

        it 'converts the value into `crop`' do
          is_expected.to match /crop/
          is_expected.not_to match /true/
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
    end

    describe '#cropping_mask' do
      subject { picture_style.cropping_mask }

      context 'with crop values given' do
        let(:picture_style) { build_stubbed(:picture_style, crop_from: '0x0', crop_size: '100x100') }

        it "returns a hash containing cropping coordinates" do
          is_expected.to eq({x1: 0, y1: 0, x2: 100, y2: 100})
        end
      end

      context 'with no crop values given' do
        let(:picture_style) { build_stubbed(:picture_style) }

        it { is_expected.to be_nil }
      end
    end

  end
end
