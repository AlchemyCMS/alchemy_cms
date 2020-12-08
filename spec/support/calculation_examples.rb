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
  end
end
