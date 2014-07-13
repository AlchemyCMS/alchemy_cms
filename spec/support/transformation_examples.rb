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

      it "should return a Hash" do
        expect(picture.default_mask({ width: 10, height: 10 })).to be_a(Hash)
      end

      it "should return a Hash with four keys x1, x2, y1, y2" do
        expect(picture.default_mask({ width: 10, height: 10 }).keys.sort).to eq([:x1, :x2, :y1, :y2])
      end

      it "should return a Hash where all values are Integer" do
        expect(picture.default_mask({ width: 13, height: 13 }).all? do |k, v|
          v.is_a? Integer
        end).to be_truthy
      end

      context "making a default cropping mask" do
        it "to 200x50 pixel, the hash should be {x1: 0, y1: 25, x2: 200, y2: 75}" do
          expect(picture.default_mask({ width: 200, height: 50 })).to eq({x1: 0, y1: 25, x2: 200, y2: 75})
        end

        it "to 0x0 pixel, it should not crop the picture" do
          expect(picture.default_mask({ width: 0, height: 0 })).to eq({x1: 0, y1: 0, x2: 200, y2: 100})
        end

        it "to 50x100 pixel, the hash should be {x1: 75, y1: 0, x2: 125, y2: 100}" do
          expect(picture.default_mask({ width: 50, height: 100 })).to eq({x1: 75, y1: 0, x2: 125, y2: 100})
        end

        it "to 50x50 pixel, the hash should be {x1: 50, y1: 0, x2: 150, y2: 100}" do
          expect(picture.default_mask({ width: 50, height: 50 })).to eq({x1: 50, y1: 0, x2: 150, y2: 100})
        end

        it "to 400x200 pixel, the hash should be {x1: 0, y1: 0, x2: 200, y2: 100}" do
          expect(picture.default_mask({ width: 400, height: 200 })).to eq({x1: 0, y1: 0, x2: 200, y2: 100})
        end

        it "to 400x100 pixel, the hash should be {x1: 0, y1: 25, x2: 200, y2: 75}" do
          expect(picture.default_mask({ width: 400, height: 100 })).to eq({x1: 0, y1: 25, x2: 200, y2: 75})
        end

        it "to 200x200 pixel, the hash should be {x1: 50, y1: 0, x2: 150, y2: 100}" do
          expect(picture.default_mask({ width: 200, height: 200 })).to eq({x1: 50, y1: 0, x2: 150, y2: 100})
        end
      end

    end

    describe "#can_be_cropped_to" do

      context "picture is 300x400 and shall be cropped to 200x100" do
        it "should return true" do
          picture.stub(:image_file_width) { 400 }
          picture.stub(:image_file_height) { 300 }

          expect(picture.can_be_cropped_to("200x100")).to be_truthy
        end
      end

      context "picture is 300x400 and shall be cropped to 600x500" do
        it "should return false" do
          picture.stub(:image_file_width) { 400 }
          picture.stub(:image_file_height) { 300 }

          expect(picture.can_be_cropped_to("600x500")).to be_falsey
        end
      end

      context "picture is 300x400 and shall be cropped to 600x500 with upsample set to true" do
        it "should return true" do
          picture.stub(:image_file_width) { 400 }
          picture.stub(:image_file_height) { 300 }

          expect(picture.can_be_cropped_to("600x500", true)).to be_truthy
        end
      end
    end
  end
end
