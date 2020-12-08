# frozen_string_literal: true

require "rails_helper"

module Alchemy
  shared_examples_for "has image render_cropping" do
    describe "#validate_gravity" do
      it "raises error if gravity param is not a hash" do
        expect{ picture.validate_gravity("string") }.to raise_error(ArgumentError)
      end

      it "raises error if non-available gravity option passed in" do
        expect{ picture.validate_gravity({ x: "unknown" }) }.to raise_error(ArgumentError)
      end
    end

    describe "#adjust_crop_area_to_aspect_ratio" do
      context "With different gravity options" do
        before do
          allow(picture).to receive(:image_file_width) { 800 }
          allow(picture).to receive(:image_file_height) { 800 }
        end
        # User center cropped 2:1 in 800x800 picture
        # Now render requested crop area 400x400 1:1 aspect ratio
        let(:size) { { width: 400, height: 400 } }
        let(:crop_from) { { x: 200, y: 300 } }
        let(:crop_size) { { width: 400, height: 200 } }

        let(:gravity) do # default_gravity
          {
            size: "grow",
            x: "center",
            y: "center",
          }
        end

        it "applies default gravity grow/center/center" do
          new_crop_from, new_crop_size = picture.adjust_crop_area_to_aspect_ratio(size, crop_from, crop_size, gravity)
          expect(new_crop_from).to eq({ x: 200, y: 200 }) # Will grow back to ar = 1 by grow height
          expect(new_crop_size).to eq({ width: 400, height: 400 })
        end

        it "applies size = shrink" do
          gravity[:size] = "shrink"

          new_crop_from, new_crop_size = picture.adjust_crop_area_to_aspect_ratio(size, crop_from, crop_size, gravity)

          expect(new_crop_from).to eq({ x: 300, y: 300 }) # Shrinks width to ar = 1
          expect(new_crop_size).to eq({ width: 200, height: 200 })
        end

        it "applies size = closest_fit" do
          # Meaning half growth and half shrink to fit
          gravity[:size] = "closest_fit"

          new_crop_from, new_crop_size = picture.adjust_crop_area_to_aspect_ratio(size, crop_from, crop_size, gravity)

          expect(new_crop_from).to eq({ x: 250, y: 250 })
          expect(new_crop_size).to eq({ width: 300, height: 300 })
        end

        it "applies y = top" do
          gravity[:y] = "top"

          new_crop_from, new_crop_size = picture.adjust_crop_area_to_aspect_ratio(size, crop_from, crop_size, gravity)

          expect(new_crop_from).to eq({ x: 200, y: 300 }) # Still 300 from top. Would've been 200 if centered
          expect(new_crop_size).to eq({ width: 400, height: 400 })
        end

        it "applies y = bottom" do
          gravity[:y] = "bottom"

          new_crop_from, new_crop_size = picture.adjust_crop_area_to_aspect_ratio(size, crop_from, crop_size, gravity)

          expect(new_crop_from).to eq({ x: 200, y: 100 }) # y now grows upwards as bottom is maintained
          expect(new_crop_size).to eq({ width: 400, height: 400 })
        end

        it "applies x = left" do
          size = { width: 400, height: 100} # ar 4
          gravity[:x] = "left"

          new_crop_from, new_crop_size = picture.adjust_crop_area_to_aspect_ratio(size, crop_from, crop_size, gravity)

          expect(new_crop_from).to eq({ x: 200, y: 325 }) # Maintains x 200, can't grow fully so has to shrink height 50px to fix aspect ratio
          expect(new_crop_size).to eq({ width: 600, height: 150 })
        end

        it "applies x = right" do
          size = { width: 400, height: 100} # ar 4
          gravity[:x] = "right"

          new_crop_from, new_crop_size = picture.adjust_crop_area_to_aspect_ratio(size, crop_from, crop_size, gravity)

          expect(new_crop_from).to eq({ x: 0, y: 325 }) # Now right side maintained so x grows left, hence no offset left => x = 0
          expect(new_crop_size).to eq({ width: 600, height: 150 })
        end
      end
    end

    describe "#shrink_crop_area" do
      # Different gravities mostly tested holistically in #get_crop_area instead of here
      it "can shrink crop area horizontally" do
        crop_size = { width: 400, height: 400 }
        size = { width: 400, height: 200 }

        expect(picture.shrink_crop_area(size, crop_size)).to eq({
          width: 400,
          height: 200,
        })
      end

      it "can shrink crop area vertically" do
        crop_size = { width: 400, height: 400 }
        size = { width: 200, height: 400 }

        expect(picture.shrink_crop_area(size, crop_size)).to eq({
          width: 200,
          height: 400,
        })
      end
    end

    describe "#grow_crop_area" do
      before do
        allow(picture).to receive(:image_file_width) { 800 }
        allow(picture).to receive(:image_file_height) { 800 }
      end

      let(:crop_from) { {x: 200, y: 200} } # centered 400x400 inside 800x800 original image
      let(:crop_size) { {width: 400, height: 400} }
      let(:gravity) {
        {
          size: "grow",
          x: "center",
          y: "center",
        }
      }

      it "can grow crop area horizontally" do
        size = {width: 400, height: 200} # ar 2
        dim = picture.grow_crop_area(size, crop_from, crop_size, gravity)
        expect(dim).to eq({
          width: 800,
          height: 400,
        })
      end

      it "can grow crop area vertically" do
        size = {width: 200, height: 400} # ar 0.5
        dim = picture.grow_crop_area(size, crop_from, crop_size, gravity)
        expect(dim).to eq({
          width: 400,
          height: 800,
        })
      end

      it "can apply closest_fit" do
        size = {width: 400, height: 200} # ar 2
        dim = picture.grow_crop_area(size, crop_from, crop_size, gravity, true)
        expect(dim).to eq({
          width: 600,
          height: 300,
        })
      end

      # Edge case
      it "can shrink instead of grow to fix aspect ratio when growing not possible" do
        size = {width: 400, height: 200}
        crop_from[:x] = 0 # But since there's no space to grow left it should shrink height instead to maintain center

        dim = picture.grow_crop_area(size, crop_from, crop_size, gravity)
        expect(dim).to eq({
          width: 400,
          height: 200,
        })
      end
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
      before do
        allow(picture).to receive(:image_file_width) { 800 }
        allow(picture).to receive(:image_file_height) { 800 }
      end

      let(:gravity) {
        {
          size: "grow",
          x: "center",
          y: "center",
        }
      }

      it "returns theoretical growth needed to fit requested aspect ratio" do
        # Without taking original image size limits into consideration - thats what max_crop_area_growth does
        crop_size = {width: 400, height: 400}
        size = {width: 400, height: 200}

        wanted_growth = picture.wanted_crop_area_growth(size, crop_size, gravity)

        expect(wanted_growth).to eq({
          top: 0,
          right: 200,
          bottom: 0,
          left: 200,
        })
      end
    end

    describe "#halve_growth" do
      it "halves growth values" do
        growth = {
          top: 200,
          bottom: 200,
          left: 0,
          right: 0,
        }

        expect(picture.halve_growth(growth)).to eq({
          top: 100,
          bottom: 100,
          left: 0,
          right: 0,
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

    describe "#round_dimensions" do
      it "rounds dimensions to whole integers" do
        size = { width: 200.5, height: 200.4 }
        rounded_size = picture.round_dimensions(size)

        expect(rounded_size).to eq({ width: 201, height: 200 })
      end
    end

    describe "#aspect_ratio" do
      it "returns aspect ratio width/height" do
        size = { width: 200, height: 400 }
        aspect_ratio = picture.aspect_ratio(size)

        expect(aspect_ratio).to eq(0.5)
      end
    end

    describe "#has_wider_aspect_ratio?" do
      it "returns wanted growth limited to max growth constraints" do
        size1 = { width: 400, height: 200 }
        size2 = { width: 200, height: 400 }
        is_wider = picture.has_wider_aspect_ratio?(size1, size2)

        expect(is_wider).to be_truthy
      end
    end
  end
end
