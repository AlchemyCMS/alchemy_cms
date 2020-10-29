# frozen_string_literal: true

require "rails_helper"

module Alchemy
  shared_examples_for "has image calculations" do
    describe "#can_be_cropped_to?" do
      context "picture is 300x400 and shall be cropped to 200x100" do
        it "should return true" do
          allow(picture).to receive(:image_file_width) { 400 }
          allow(picture).to receive(:image_file_height) { 300 }

          expect(picture.can_be_cropped_to?("200x100")).to be(true)
        end
      end

      context "picture is 300x400 and shall be cropped to 600x500" do
        it "should return false" do
          allow(picture).to receive(:image_file_width) { 400 }
          allow(picture).to receive(:image_file_height) { 300 }

          expect(picture.can_be_cropped_to?("600x500")).to be(false)
        end
      end

      context "picture is 300x400 and shall be cropped to 600x500 with upsample set to true" do
        it "should return true" do
          allow(picture).to receive(:image_file_width) { 400 }
          allow(picture).to receive(:image_file_height) { 300 }

          expect(picture.can_be_cropped_to?("600x500", true)).to be(true)
        end
      end
    end

    describe "#adjust_crop_area_to_aspect_ratio" do
      # Different gravities mostly tested holistically in #get_crop_area instead of here
      it "adjusts crop_from and crop_size to requested size aspect ratio" do
        allow(picture).to receive(:image_file_width) { 800 }
        allow(picture).to receive(:image_file_height) { 800 }
        crop_from = {x: 400, y: 400}
        crop_size = {width: 400, height: 400} # square in bottom right corner
        crop_ar = 1
        size_ar = 2 # wants 800x400
        gravity = { size: "grow", x: "right", y: "bottom" } # Maintain bottom right to allow growing top left

        new_crop_from, new_crop_size = picture.adjust_crop_area_to_aspect_ratio(crop_from, crop_size, size_ar, crop_ar, gravity)
        expect(new_crop_from).to eq({ x: 0, y: 400 }) # Now right side maintained so x grows left, hence no offset left => x = 0
        expect(new_crop_size).to eq({ width: 800, height: 400 })
      end
    end

    describe "#shrink_crop_area" do
      # Different gravities mostly tested holistically in #get_crop_area instead of here
      it "can shrink crop area horizontally" do
        crop_size = { width: 400, height: 400 }
        size_ar = 2.0 # width / height => 2:1
        crop_ar = 1.0

        expect(picture.shrink_crop_area(crop_size, size_ar, crop_ar)).to eq({
          width: 400,
          height: 200,
        })
      end

      it "can shrink crop area vertically" do
        crop_size = { width: 400, height: 400 }
        size_ar = 0.5 # width / height => 1:2
        crop_ar = 1.0

        expect(picture.shrink_crop_area(crop_size, size_ar, crop_ar)).to eq({
          width: 200,
          height: 400,
        })
      end
    end

    describe "#grow_crop_area" do
      # Different gravities mostly tested holistically in #get_crop_area instead of here
      before do
        allow(picture).to receive(:image_file_width) { 800 }
        allow(picture).to receive(:image_file_height) { 800 }
      end

      crop_from = {x: 200, y: 200} # centered 400x400 inside 800x800 original image
      crop_size = {width: 400, height: 400}
      crop_ar = 1.0
      gravity = {
        size: "grow",
        x: "center",
        y: "center",
      }

      after(:each) do
        crop_from = {x: 200, y: 200}
        crop_size = {width: 400, height: 400}
        gravity = {
          size: "grow",
          x: "center",
          y: "center",
        }
      end

      it "can grow crop area horizontally" do
        size_ar = 2.0
        dim = picture.grow_crop_area(crop_from, crop_size, size_ar, crop_ar, gravity)
        expect(dim).to eq({
          width: 800,
          height: 400,
        })
      end

      it "can grow crop area vertically" do
        size_ar = 0.5
        dim = picture.grow_crop_area(crop_from, crop_size, size_ar, crop_ar, gravity)
        expect(dim).to eq({
          width: 400,
          height: 800,
        })
      end

      it "can apply closest_fit" do
        size_ar = 2.0
        dim = picture.grow_crop_area(crop_from, crop_size, size_ar, crop_ar, gravity, true)
        expect(dim).to eq({
          width: 600,
          height: 300,
        })
      end

      # Edge case
      it "can shrink instead of grow to fix aspect ratio when growing not possible" do
        size_ar = 2.0 # wants to grow horizontally from 400x400 => 800x400
        crop_from[:x] = 0 # But since there's no space to grow left it should shrink height instead to maintain center

        dim = picture.grow_crop_area(crop_from, crop_size, size_ar, crop_ar, gravity)
        expect(dim).to eq({
          width: 400,
          height: 200,
        })
      end

      describe "#max_crop_area_growth" do
        it "should limit max crop area growth to original image size" do
          allow(picture).to receive(:image_file_width) { 800 }
          allow(picture).to receive(:image_file_height) { 800 }

          crop_from = {x: 100, y: 300}
          crop_size = {width: 300, height: 500}

          max_growth = picture.max_crop_area_growth(crop_from, crop_size)

          expect(max_growth).to eq({
            top: 300,
            right: 400,
            bottom: 0,
            left: 100,
          })
        end
      end

      describe "#wanted_crop_area_growth" do
        it "returns growth needed to fit requested aspect ratio" do
          # Without taking original image size limits into consideration - thats what max_crop_area_growth does
          crop_size = {width: 400, height: 400}
          crop_ar = 1
          size_ar = 2 # Wants to grow to 800x400

          wanted_growth = picture.wanted_crop_area_growth(crop_size, size_ar, crop_ar, gravity)

          expect(wanted_growth).to eq({
            top: 0,
            right: 200,
            bottom: 0,
            left: 200,
          })
        end
      end

      describe "#actual_crop_area_growth" do
        it "returns wanted growth limited to max growth constraints" do
          wanted_growth = {
            top: 200,
            bottom: 200,
            left: 0,
            right: 0,
          }
          max_growth = {
            top: 100,
            bottom: 200,
            left: 0,
            right: 0,
          }

          actual_growth = picture.actual_crop_area_growth(wanted_growth, max_growth)

          # Growth in two directions indicates gravity center, hence both will be constrained
          # to the minimum of corresponding max growth values
          expect(actual_growth).to eq({
            top: 100,
            bottom: 100,
            right: 0,
            left: 0,
          })
        end
      end
    end
  end
end
