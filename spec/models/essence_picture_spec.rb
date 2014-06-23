require 'spec_helper'

module Alchemy
  describe EssencePicture do
    it_behaves_like "an essence" do
      let(:essence)          { EssencePicture.new }
      let(:ingredient_value) { Picture.new }
    end

    it "should not store negative values for crop values" do
      essence = EssencePicture.new(:crop_from => '-1x100', :crop_size => '-20x30')
      essence.save!
      essence.crop_from.should == "0x100"
      essence.crop_size.should == "0x30"
    end

    it "should not store float values for crop values" do
      essence = EssencePicture.new(:crop_from => '0.05x104.5', :crop_size => '99.5x203.4')
      essence.save!
      essence.crop_from.should == "0x105"
      essence.crop_size.should == "100x203"
    end

    it "should convert newlines in caption into <br/>s" do
      essence = EssencePicture.new(:caption => "hello\nkitty")
      essence.save!
      essence.caption.should == "hello<br/>kitty"
    end

    describe '#picture_url' do
      subject { essence.picture_url(options) }

      let(:options) { {} }
      let(:picture) { build_stubbed(:picture) }
      let(:essence) { build_stubbed(:essence_picture, picture: picture) }

      it "returns the show picture url." do
        should match(/\/pictures\/#{picture.id}\/show\/#{picture.urlname}\.#{Config.get(:image_output_format)}/)
      end

      it "includes the secure hash." do
        should match(/\?sh=\S+\z/)
      end

      context 'with size in the options' do
        let(:options) { {size: '200x300'} }

        it "includes the size in the url." do
          should match(/200x300/)
        end
      end

      context 'with no format in the options' do
        it "includes the default image output format." do
          should match(/#{Config.get(:image_output_format)}/)
        end
      end

      context 'with format in the options' do
        let(:options) { {format: 'png'} }

        it "takes this as format." do
          should match(/png/)
        end
      end

      context 'with crop sizes set' do
        before { essence.stub(crop_size: '200x200', crop_from: '10x10') }

        it "includes the crop sizes in the url." do
          should match(/200x200/)
          should match(/10x10/)
        end

        context 'but with crop sizes in the options' do
          let(:options) { {crop_from: '30x30', crop_size: '75x75'} }

          it "includes these crop sizes instead." do
            should match(/30x30/)
            should match(/75x75/)
          end
        end
      end

      context 'with crop true in the options' do
        let(:options) { {crop: true} }

        it 'converts the value into `crop`' do
          should match /crop/
          should_not match /true/
        end
      end

      context 'with `image_size` in the options' do
        let(:options) { {image_size: '100x100'} }

        it 'converts the key into `size`' do
          should match /100x100/
        end
      end

      context 'with other options' do
        let(:options) { {foo: 'baz'} }

        it 'it removes them from params' do
          should_not match /foo/
        end
      end

      context 'without picture assigned' do
        let(:picture) { nil }

        it { should be_nil }
      end
    end

    describe '#cropping_mask' do
      subject { essence.cropping_mask }

      context 'with crop values given' do
        let(:essence) { build_stubbed(:essence_picture, crop_from: '0x0', crop_size: '100x100') }

        it "returns a hash containing cropping coordinates" do
          should == {x1: 0, y1: 0, x2: 100, y2: 100}
        end
      end

      context 'with no crop values given' do
        let(:essence) { build_stubbed(:essence_picture) }

        it { should be_nil }
      end
    end

    describe '#preview_text' do
      let(:picture) { mock_model(Picture, name: 'Cute Cat Kittens')}
      let(:essence) { EssencePicture.new }

      it "should return the pictures name as preview text" do
        essence.stub(:picture).and_return(picture)
        essence.preview_text.should == 'Cute Cat Kittens'
      end

      context "with no picture assigned" do
        it "returns empty string" do
          essence.preview_text.should == ''
        end
      end
    end

    describe '#default_mask' do

      let(:picture) { mock_model(Picture, image_file_width: 200, image_file_height: 100)}
      let(:essence) { EssencePicture.new }
      let(:essence_without_pic) { EssencePicture.new }


      before do
        essence.stub(:picture).and_return(picture)
      end

      it "should raise an error if there is no image" do
        expect { essence_without_pic.default_mask() }.to raise_error("No picture associated")
      end

      it "should raise an error if the argument is empty" do
        expect { essence.default_mask("") }.to raise_error("No size given")
      end

      it "should return a Hash" do
        expect(essence.default_mask('10x10')).to be_a(Hash)
      end

      it "should return a Hash with four keys x1, x2, y1, y2" do
        expect(essence.default_mask('10x10').keys.sort).to eq([:x1, :x2, :y1, :y2])
      end

      it "should return a Hash where all values are Integer" do
        expect(essence.default_mask("131313x13131313").all? do |k, v|
          v.is_a? Integer
        end).to be_truthy
      end

      context "cropping the picture to 200x50 pixel" do
        it "should contain the correct coordination values in the hash" do
          expect(essence.default_mask('200x50')).to eq({x1: 0, y1: 25, x2: 200, y2: 75})
        end
      end

      context "if picture's cropping size is 0x0 pixel" do
        it "should not crop the picture" do
          expect(essence.default_mask('0x0')).to eq({x1: 0, y1: 0, x2: 200, y2: 100})
        end
      end

      context "cropping the picture to 50x100 pixel" do
        it "should contain the correct coordination values in the hash" do
          expect(essence.default_mask('50x100')).to eq({x1: 75, y1: 0, x2: 125, y2: 100})
        end
      end

      context "cropping the picture to 50x50 pixels" do
        it "should contain the correct coordination values in the hash" do
          expect(essence.default_mask('50x50')).to eq({x1: 50, y1: 0, x2: 150, y2: 100})
        end
      end

      context "cropping the picture to a bigger image (400x200) with same ratio" do
        it "should contain the correct coordination values in the hash" do
          expect(essence.default_mask('400x200')).to eq({x1: 0, y1: 0, x2: 200, y2: 100})
        end
      end

      context "cropping the picture to a bigger image (400x100) with low height" do
        it "should contain the correct coordination values in the hash" do
          expect(essence.default_mask('400x100')).to eq({x1: 0, y1: 25, x2: 200, y2: 75})
        end
      end

      context "cropping the picture to a bigger image (200x200) with low width" do
        it "should contain the correct coordination values in the hash" do
          expect(essence.default_mask('200x200')).to eq({x1: 50, y1: 0, x2: 150, y2: 100})
        end
      end
    end

  end
end
