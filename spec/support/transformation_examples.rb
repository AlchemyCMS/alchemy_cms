# frozen_string_literal: true

require "rails_helper"

module Alchemy
  shared_examples_for "has image transformations" do
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
  end
end
