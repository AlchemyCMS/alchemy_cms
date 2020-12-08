# frozen_string_literal: true

require "rails_helper"

module Alchemy
  shared_examples_for "has image transformations" do
    it_behaves_like "has image render_cropping"

    describe "#thumbnail_size" do
      context "picture is 300x400 and has no crop size" do
        it "should return the correct recalculated size value" do
          allow(picture).to receive(:image_file_width) { 400 }
          allow(picture).to receive(:image_file_height) { 300 }

          expect(picture.thumbnail_size).to eq("160x120")
        end
      end

      context "picture is 300x400 and has no crop size" do
        it "should return the correct recalculated size value" do
          allow(picture).to receive(:image_file_width) { 300 }
          allow(picture).to receive(:image_file_height) { 400 }

          expect(picture.thumbnail_size).to eq("90x120")
        end
      end

      context "picture has crop_size of 400x300" do
        it "scales to 400x300 if that is the size of the cropped image" do
          allow(picture).to receive(:crop_size) { "400x300" }
          expect(picture.thumbnail_size).to eq("160x120")
        end
      end

      context "picture has crop_size of 0x0" do
        it "returns default thumbnail size" do
          allow(picture).to receive(:crop_size) { "0x0" }
          expect(picture.thumbnail_size).to eq("160x120")
        end
      end
    end

    describe "#landscape_format?" do
      subject { picture.landscape_format? }

      context "image has landscape format" do
        before { allow(picture).to receive(:image_file).and_return double(landscape?: true) }

        it { is_expected.to be_truthy }
      end

      context "image has portrait format" do
        before { allow(picture).to receive(:image_file).and_return double(landscape?: false) }

        it { is_expected.to be_falsey }
      end

      it "is aliased as landscape?" do
        expect(picture.respond_to?(:landscape?)).to be_truthy
      end
    end

    describe "#portrait_format?" do
      subject { picture.portrait_format? }

      context "image has portrait format" do
        before { allow(picture).to receive(:image_file).and_return double(portrait?: true) }

        it { is_expected.to be_truthy }
      end

      context "image has landscape format" do
        before { allow(picture).to receive(:image_file).and_return double(portrait?: false) }

        it { is_expected.to be_falsey }
      end

      it "is aliased as portrait?" do
        expect(picture.respond_to?(:portrait?)).to be_truthy
      end
    end

    describe "#square_format?" do
      subject { picture.square_format? }

      context "image has square format" do
        before { expect(picture).to receive(:image_file).and_return double(aspect_ratio: 1.0) }

        it { is_expected.to be_truthy }
      end

      context "image has rectangle format" do
        before { expect(picture).to receive(:image_file).and_return double(aspect_ratio: 8.0) }

        it { is_expected.to be_falsey }
      end

      it "is aliased as square?" do
        expect(picture.respond_to?(:square?)).to be_truthy
      end
    end

    describe "#default_mask" do
      before do
        allow(picture).to receive(:image_file_width) { 200 }
        allow(picture).to receive(:image_file_height) { 100 }
      end

      it "should return a Hash" do
        expect(picture.default_mask({ width: 10, height: 10 })).to be_a(Hash)
      end

      it "should return a Hash with four keys x1, x2, y1, y2" do
        expect(picture.default_mask({ width: 10, height: 10 }).keys.sort).to eq([:x1, :x2, :y1, :y2])
      end

      it "should return a Hash where all values are Integer" do
        expect(picture.default_mask({ width: 13, height: 13 }).all? do |_k, v|
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

    # This is the main crop area method where most functionality is tested
    #
    describe "#get_crop_area" do
      before do
        allow(picture).to receive(:image_file_width) { 800 }
        allow(picture).to receive(:image_file_height) { 800 }
      end

      let(:size) { nil }
      let(:render_size) { nil }
      let(:crop_from) { nil }
      let(:crop_size) { nil }
      let(:render_crop) { nil }
      let(:gravity) do
        {
          size: "grow",
          x: "center",
          y: "center",
        }
      end

      context "without render_crop" do
        it "crops to user crop first if set (crop_from/crop_size)" do
          # Given size would only resize the final images pixel size in render
          crop_from = "200x300"
          crop_size = "400x200"
          render_size = "800x800"
          size = "800x400"

          new_crop_from, new_crop_size = picture.get_crop_area(size, render_size, crop_from, crop_size, render_crop, gravity)

          expect(new_crop_from).to eq({ x: 200, y: 300 })
          expect(new_crop_size).to eq({ width: 400, height: 200 })
        end

        it "crops to user size selection (render_size) before size if user hasn't cropped (crop_from/crop_size)" do
          # ... As given size would only resize the final images pixel size in render
          render_size = "400x800"
          size = "800x400"

          new_crop_from, new_crop_size = picture.get_crop_area(size, render_size, crop_from, crop_size, render_crop, gravity)

          expect(new_crop_from).to eq({ x: 200, y: 0 })
          expect(new_crop_size).to eq({ width: 400, height: 800 })
        end

        it "crops to size if no crop_from/crop_size/render_size given" do
          # Without any user applied overrides, size will crop instead of only resize as crop = true (even though render_crop = false)
          size = "800x400"

          new_crop_from, new_crop_size = picture.get_crop_area(size, render_size, crop_from, crop_size, render_crop, gravity)

          expect(new_crop_from).to eq({ x: 0, y: 200 })
          expect(new_crop_size).to eq({ width: 800, height: 400 })
        end
      end

      context "with render_crop" do
        let(:render_crop) { true }
        # User has center cropped 400x200, 2:1 in our 800x800 (1:1) base image
        let(:crop_from) { "200x300" }
        let(:crop_size) { "400x200" }
        # This size will now be used to adjust crop area back to to 1:1 aspect ratio from user cropped 2:1
        let(:size) { "800x800" }

        it "adjusts aspect ratio of a user cropped area (crop_from/crop_size) to fit requested size" do
          new_crop_from, new_crop_size = picture.get_crop_area(size, render_size, crop_from, crop_size, render_crop, gravity)

          expect(new_crop_from).to eq({ x: 200, y: 200 })
          expect(new_crop_size).to eq({ width: 400, height: 400 })
        end

        it "adjusts aspect ratio of a user selected render_size to fit requested size" do
          crop_from, crop_size = [nil, nil]
          # render_size 400x200 will actually crop 800x400 as it is applying default mask which expands to cover as much as possible of original image
          # Then the pixel size will be reduced later on
          render_size = "400x200"

          new_crop_from, new_crop_size = picture.get_crop_area(size, render_size, crop_from, crop_size, render_crop, gravity)

          expect(new_crop_from).to eq({ x: 0, y: 0 })
          expect(new_crop_size).to eq({ width: 800, height: 800 })
        end
      end
    end
  end
end
