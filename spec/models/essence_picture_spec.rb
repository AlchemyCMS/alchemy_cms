require 'spec_helper'

module Alchemy
  describe EssencePicture do
    it_behaves_like "an essence" do
      let(:essence)          { EssencePicture.new }
      let(:ingredient_value) { Picture.new }
    end

    it_behaves_like "has image transformations" do
      let(:picture) { build_stubbed(:essence_picture) }
    end


    it "should not store negative values for crop values" do
      essence = EssencePicture.new(:crop_from => '-1x100', :crop_size => '-20x30')
      essence.save!
      expect(essence.crop_from).to eq("0x100")
      expect(essence.crop_size).to eq("0x30")
    end

    it "should not store float values for crop values" do
      essence = EssencePicture.new(:crop_from => '0.05x104.5', :crop_size => '99.5x203.4')
      essence.save!
      expect(essence.crop_from).to eq("0x105")
      expect(essence.crop_size).to eq("100x203")
    end

    it "should convert newlines in caption into <br/>s" do
      essence = EssencePicture.new(:caption => "hello\nkitty")
      essence.save!
      expect(essence.caption).to eq("hello<br/>kitty")
    end

    describe '#picture_url' do
      subject { essence.picture_url(options) }

      let(:options) { {} }
      let(:picture) { build_stubbed(:picture) }
      let(:essence) { build_stubbed(:essence_picture, picture: picture) }

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
        before { essence.stub(crop_size: '200x200', crop_from: '10x10') }

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

      context 'without picture assigned' do
        let(:picture) { nil }

        it { is_expected.to be_nil }
      end
    end

    describe '#cropping_mask' do
      subject { essence.cropping_mask }

      context 'with crop values given' do
        let(:essence) { build_stubbed(:essence_picture, crop_from: '0x0', crop_size: '100x100') }

        it "returns a hash containing cropping coordinates" do
          is_expected.to eq({x1: 0, y1: 0, x2: 100, y2: 100})
        end
      end

      context 'with no crop values given' do
        let(:essence) { build_stubbed(:essence_picture) }

        it { is_expected.to be_nil }
      end
    end

    describe '#preview_text' do
      let(:picture) { mock_model(Picture, name: 'Cute Cat Kittens')}
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

  end
end
