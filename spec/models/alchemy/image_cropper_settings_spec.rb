# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::ImageCropperSettings do
  let(:image_cropper_settings) do
    described_class.new(
      render_size: render_size,
      crop_from: crop_from,
      crop_size: crop_size,
      fixed_ratio: fixed_ratio,
      image_width: image_width,
      image_height: image_height,
    )
  end

  describe "#to_h" do
    let(:render_size) { nil }
    let(:crop_from) { nil }
    let(:crop_size) { nil }
    let(:fixed_ratio) { nil }
    let(:image_width) { nil }
    let(:image_height) { nil }

    subject { image_cropper_settings.to_h }

    context "without image sizes" do
      it { is_expected.to eq({}) }
    end

    context "with image sizes given" do
      let(:image_width) { 300 }
      let(:image_height) { 250 }

      describe ":min_size" do
        subject(:min_size) { image_cropper_settings[:min_size] }

        context "with render_size given" do
          context "that matches the image dimensions" do
            let(:render_size) { "300x250" }

            it "sets min_size to given values" do
              expect(min_size).to eq([300, 250])
            end
          end

          context "that is smaller than the image dimensions" do
            let(:render_size) { "30x25" }

            it "sets min_size to given values" do
              expect(min_size).to eq([30, 25])
            end
          end

          context "that is larger than the image dimensions" do
            let(:render_size) { "3000x2500" }

            it { expect(min_size).to be(false) }
          end

          context "when height is not fixed" do
            let(:render_size) { "30x" }

            it "infers the height from the image file preserving the aspect ratio" do
              expect(min_size).to eq([30, 0])
            end

            context "and fixed_ratio set to integer" do
              let(:fixed_ratio) { "2" }

              it "it infers the height from width and ratio" do
                expect(min_size).to eq([30, 15])
              end
            end

            context "and fixed_ratio set to float" do
              let(:fixed_ratio) { "0.5" }

              it "it infers the height from width and ratio" do
                expect(min_size).to eq([30, 60])
              end
            end
          end

          context "when height is not fixed" do
            let(:render_size) { "x25" }

            it "infers the height from the image file preserving the aspect ratio" do
              expect(min_size).to eq([0, 25])
            end
          end
        end

        context "with render_size blank" do
          it "sets min_size to zero" do
            expect(min_size).to eq([0, 0])
          end
        end
      end

      describe ":default_box" do
        subject(:default_box) { image_cropper_settings[:default_box] }

        it "should return an Array with four values" do
          expect(default_box.length).to eq(4)
        end

        it "should return an Array where all values are Integer" do
          expect(default_box.all? { |v| v.is_a? Integer }).to be_truthy
        end

        context "making a default cropping mask" do
          let(:image_width) { 200 }
          let(:image_height) { 100 }

          context "render_size 200x50" do
            let(:render_size) { "200x50" }

            it "the hash should be {x1: 0, y1: 25, x2: 200, y2: 75}" do
              expect(default_box).to eq([0, 25, 200, 75])
            end
          end

          context "render_size 0x0" do
            let(:render_size) { "0x0" }

            it "it should not crop the picture" do
              expect(default_box).to eq([0, 0, 200, 100])
            end
          end

          context "render_size 50x100" do
            let(:render_size) { "50x100" }

            it "the hash should be {x1: 75, y1: 0, x2: 125, y2: 100}" do
              expect(default_box).to eq([75, 0, 125, 100])
            end
          end

          context "render_size 50x50" do
            let(:render_size) { "50x50" }

            it "the hash should be {x1: 50, y1: 0, x2: 150, y2: 100}" do
              expect(default_box).to eq([50, 0, 150, 100])
            end
          end

          context "render_size 400x200" do
            let(:render_size) { "400x200" }

            it "the hash should be {x1: 0, y1: 0, x2: 200, y2: 100}" do
              expect(default_box).to eq([0, 0, 200, 100])
            end
          end

          context "render_size 400x100" do
            let(:render_size) { "400x100" }

            it "the hash should be {x1: 0, y1: 25, x2: 200, y2: 75}" do
              expect(default_box).to eq([0, 25, 200, 75])
            end
          end

          context "render_size 200x200" do
            let(:render_size) { "200x200" }

            it "the hash should be {x1: 50, y1: 0, x2: 150, y2: 100}" do
              expect(default_box).to eq([50, 0, 150, 100])
            end
          end
        end
      end

      describe ":ratio" do
        context "with fixed_ratio set to false" do
          let(:settings) do
            { fixed_ratio: false }
          end

          it "sets ratio to false" do
            expect(subject[:ratio]).to eq(false)
          end
        end

        context "with fixed_ratio set to a non float string" do
          let(:fixed_ratio) { "123,45" }

          it "doesn't set a fixed ratio" do
            expect(subject[:ratio]).to eq(false)
          end
        end

        context "with no fixed_ratio set" do
          let(:render_size) { "80x60" }

          it "sets a fixed ratio from sizes" do
            expect(subject[:ratio]).to eq(80.0 / 60.0)
          end
        end
      end

      describe ":image_size" do
        it "is an Array of image width and height" do
          expect(subject[:image_size]).to eq([300, 250])
        end
      end
    end
  end
end
