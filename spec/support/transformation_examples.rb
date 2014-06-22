require 'spec_helper'

module Alchemy
  shared_examples_for "has image transformations"  do

    describe "#thumbnail_size" do

      context "picture is 300x400 and has no crop size" do
        it "should return the correct recalculated size value" do
          picture.stub(:image_file_width) { 400 }
          picture.stub(:image_file_height) { 300 }

          expect(picture.thumbnail_size()).to eq('111x83')
        end
      end

      context "picture is 300x400 and has no crop size" do
        it "should return the correct recalculated size value" do
          picture.stub(:image_file_width) { 300 }
          picture.stub(:image_file_height) { 400 }

          expect(picture.thumbnail_size()).to eq('70x93')
        end
      end

      context "picture has crop_size of 400x300" do
        it "scales to 400x300 if that is the size of the cropped image" do
          picture.stub(:crop_size) { "400x300" }
          expect(picture.thumbnail_size()).to eq('111x83')
        end
      end
    end


    describe '#landscape_format?' do

      subject { picture.landscape_format? }

      context 'image has landscape format' do
        before { picture.stub_chain(:image_file, :landscape?).and_return(true) }
        it { should be_true }
      end

      context 'image has portrait format' do
        before { picture.stub_chain(:image_file, :landscape?).and_return(false) }
        it { should be_false }
      end

      it "is aliased as landscape?" do
        picture.respond_to?(:landscape?).should be_true
      end
    end

    describe '#portrait_format?' do
      subject { picture.portrait_format? }

      context 'image has portrait format' do
        before { picture.stub_chain(:image_file, :portrait?).and_return(true) }
        it { should be_true }
      end

      context 'image has landscape format' do
        before { picture.stub_chain(:image_file, :portrait?).and_return(false) }
        it { should be_false }
      end

      it "is aliased as portrait?" do
        picture.respond_to?(:portrait?).should be_true
      end
    end

    describe '#square_format?' do
      subject { picture.square_format? }

      context 'image has square format' do
        before { picture.stub_chain(:image_file, :aspect_ratio).and_return(1.0) }
        it { should be_true }
      end

      context 'image has rectangle format' do
        before { picture.stub_chain(:image_file, :aspect_ratio).and_return(1.8) }
        it { should be_false }
      end

      it "is aliased as square?" do
        picture.respond_to?(:square?).should be_true
      end
    end


    describe '#default_mask' do

      before do
        picture.stub(:image_file_width) { 200 }
        picture.stub(:image_file_height) { 100 }
      end

      it "should raise an error if the argument is empty" do
        expect { picture.default_mask("") }.to raise_error("No size given")
      end

      it "should return a Hash" do
        expect(picture.default_mask('10x10')).to be_a(Hash)
      end

      it "should return a Hash with four keys x1, x2, y1, y2" do
        expect(picture.default_mask('10x10').keys.sort).to eq([:x1, :x2, :y1, :y2])
      end

      it "should return a Hash where all values are Integer" do
        expect(picture.default_mask("13x13").all? do |k, v|
          v.is_a? Integer
        end).to be_truthy
      end


      context "cropping the picture with upsample false" do
        it "to 200x50 pixel, the hash should be {x1: 0, y1: 25, x2: 200, y2: 75}" do
          expect(picture.default_mask('200x50', false)).to eq({x1: 0, y1: 25, x2: 200, y2: 75})
        end

        it "to 0x0 pixel, it should not crop the picture" do
          expect(picture.default_mask('0x0', false)).to eq({x1: 0, y1: 0, x2: 200, y2: 100})
        end

        it "to 50x100 pixel, the hash should be {x1: 75, y1: 0, x2: 125, y2: 100}" do
          expect(picture.default_mask('50x100', false)).to eq({x1: 75, y1: 0, x2: 125, y2: 100})
        end

        it "to 50x50 pixel, the hash should be {x1: 50, y1: 0, x2: 150, y2: 100}" do
          expect(picture.default_mask('50x50', false)).to eq({x1: 50, y1: 0, x2: 150, y2: 100})
        end

        it "to 400x200 pixel it should raise an error" do
          expect { picture.default_mask('400x200', false) }.to raise_exception /This image is too small to crop/
        end

        it "to 400x100 pixel it should raise an error" do
          expect { picture.default_mask('400x100', false) }.to raise_error /This image is too small to crop/
        end

        it "to 200x200 pixel it should raise an error" do
          expect { picture.default_mask('200x200', false) }.to raise_error /This image is too small to crop/
        end
      end

      context "cropping the picture with upsample true" do
        it "to 200x50 pixel, the hash should be {x1: 0, y1: 25, x2: 200, y2: 75}" do
          expect(picture.default_mask('200x50', true)).to eq({x1: 0, y1: 25, x2: 200, y2: 75})
        end

        it "to 0x0 pixel, it should not crop the picture" do
          expect(picture.default_mask('0x0', true)).to eq({x1: 0, y1: 0, x2: 200, y2: 100})
        end

        it "to 50x100 pixel, the hash should be {x1: 75, y1: 0, x2: 125, y2: 100}" do
          expect(picture.default_mask('50x100', true)).to eq({x1: 75, y1: 0, x2: 125, y2: 100})
        end

        it "to 50x50 pixel, the hash should be {x1: 50, y1: 0, x2: 150, y2: 100}" do
          expect(picture.default_mask('50x50', true)).to eq({x1: 50, y1: 0, x2: 150, y2: 100})
        end

        it "to 400x200 pixel, the hash should be {x1: 0, y1: 0, x2: 200, y2: 100}" do
          expect(picture.default_mask('400x200', true)).to eq({x1: 0, y1: 0, x2: 200, y2: 100})
        end

        it "to 400x100 pixel, the hash should be {x1: 0, y1: 25, x2: 200, y2: 75}" do
          expect(picture.default_mask('400x100', true)).to eq({x1: 0, y1: 25, x2: 200, y2: 75})
        end

        it "to 200x200 pixel, the hash should be {x1: 50, y1: 0, x2: 150, y2: 100}" do
          expect(picture.default_mask('200x200', true)).to eq({x1: 50, y1: 0, x2: 150, y2: 100})
        end
      end

    end
  end
end