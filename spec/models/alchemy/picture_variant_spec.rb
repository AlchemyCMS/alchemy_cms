# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::PictureVariant, if: Alchemy.storage_adapter.dragonfly? do
  let(:image_file) do
    fixture_file_upload("500x500.png")
  end

  let(:alchemy_picture) { build(:alchemy_picture, image_file: image_file) }

  subject { described_class.new(alchemy_picture, options).image }

  let(:options) { {} }

  context "when no image is present" do
    let(:alchemy_picture) { nil }

    it "raises ArgumentError" do
      expect { subject }.to raise_error(ArgumentError)
    end
  end

  context "when a size is passed in" do
    let(:options) do
      {size: "120x160"}
    end

    it "resizes the image without upsampling it" do
      expect(subject.steps[0].arguments).to eq(["120x160>"])
    end

    context "but upsample set to true" do
      let(:options) do
        {
          size: "1600x1200",
          upsample: true
        }
      end

      it "resizes the image with upsampling it" do
        expect(subject.steps[0].arguments).to eq(["1600x1200"])
      end
    end

    context "and crop is set to true" do
      let(:options) do
        {
          size: "160x120",
          crop: true
        }
      end

      it "crops from center and resizes the picture" do
        expect(subject.steps[0].arguments).to eq(["160x120#"])
      end

      context "and crop_from and crop_size is passed in" do
        let(:options) do
          {
            crop_size: "123x44",
            crop_from: "0x0",
            size: "160x120",
            crop: true
          }
        end

        it "crops and resizes the picture" do
          expect(subject.steps[0].arguments).to eq(["123x44+0+0", "160x120>"])
        end
      end
    end

    context "and crop is set to false" do
      let(:options) do
        {
          size: "160x120",
          crop: false
        }
      end

      it "does not crop the picture" do
        expect(subject.steps[0].arguments).to eq(["160x120>"])
      end

      context "and crop_from and crop_size is passed in" do
        let(:options) do
          {
            crop_size: "123x44",
            crop_from: "0x0",
            size: "160x120",
            crop: false
          }
        end

        it "does not crop the picture" do
          expect(subject.steps[0].arguments).to eq(["160x120>"])
        end
      end
    end

    context "with no height given" do
      let(:options) do
        {size: "40"}
      end

      it "resizes the image inferring the height" do
        expect(subject.steps[0].arguments).to eq(["40>"])
      end

      context "and crop set to true" do
        let(:image_file) do
          fixture_file_upload("80x60.png")
        end
        let(:options) do
          {size: "17x", crop: true}
        end

        it "resizes the image inferring the height" do
          expect(subject.steps[0].arguments).to eq(["17x13#"])
        end
      end
    end

    context "with no width given" do
      let(:options) do
        {size: "x30"}
      end

      it "resizes the image inferring the width" do
        expect(subject.steps[0].arguments).to eq(["x30>"])
      end
    end
  end

  context "when no size is passed in" do
    it "does not process the image" do
      expect(subject.job.steps).to be_empty
    end
  end

  context "when a different format is requested" do
    let(:options) do
      {format: "gif"}
    end

    it "converts the format" do
      step = subject.steps[0]
      expect(step.name).to eq(:encode)
      expect(step.arguments).to include("gif")
    end

    context "but image has not a convertible format (svg)" do
      let(:image_file) do
        fixture_file_upload("icon.svg")
      end

      it "does not convert the picture format" do
        expect(subject.job.steps.size).to eq(0)
      end
    end

    context "for an animated gif" do
      let(:options) do
        {format: "png"}
      end

      let(:image_file) do
        fixture_file_upload("animated.gif")
      end

      it "flattens the image." do
        step = subject.steps[0]
        expect(step.name).to eq(:encode)
        expect(step.arguments).to eq(["png", "-background transparent -flatten"])
      end

      context "converted to non transparent format" do
        let(:options) do
          {format: "jpg"}
        end

        it "does not add transparent background." do
          step = subject.steps[0]
          expect(step.name).to eq(:encode)
          expect(step.arguments).to eq(["jpg", "-quality 85 -flatten"])
        end
      end

      context "converted from non transparent format" do
        let(:options) do
          {format: "png", flatten: true}
        end

        let(:image_file) do
          fixture_file_upload("image4.jpg")
        end

        it "does not add transparent background." do
          step = subject.steps[0]
          expect(step.name).to eq(:encode)
          expect(step.arguments).to eq(["png", "-flatten"])
        end
      end

      context "converted to webp" do
        let(:options) do
          {format: "webp"}
        end

        let(:image_file) do
          fixture_file_upload("animated.gif")
        end

        it "does not flatten the image." do
          step = subject.steps[0]
          expect(step.name).to eq(:encode)
          expect(step.arguments).to eq(["webp", "-quality 85"])
        end
      end
    end

    context "passed as symbol" do
      let(:options) do
        {format: :gif}
      end

      it "converts the format" do
        step = subject.steps[0]
        expect(step.name).to eq(:encode)
        expect(step.arguments).to include("gif")
      end
    end
  end

  context "requesting a not allowed format" do
    let(:options) do
      {format: "zip"}
    end

    it "returns nil" do
      expect(subject).to be_nil
    end

    it "logs warning" do
      expect(Alchemy::Logger).to receive(:warn)
      subject
    end
  end

  %w[jpg jpeg].each do |format|
    context "when #{format} format is requested" do
      let(:options) do
        {format: format}
      end

      context "and the image file format is not JPG" do
        it "sets the default quality" do
          step = subject.steps[0]
          expect(step.name).to eq(:encode)
          expect(step.arguments).to eq([format, "-quality 85"])
        end

        context "and quality is passed" do
          let(:options) do
            {format: format, quality: "30"}
          end

          it "sets the quality" do
            step = subject.steps[0]
            expect(step.name).to eq(:encode)
            expect(step.arguments).to eq([format, "-quality 30"])
          end
        end
      end

      context "and image has jpg format" do
        let(:alchemy_picture) do
          build(:alchemy_picture, image_file: fixture_file_upload("image4.jpg"))
        end

        it "does not convert the picture format" do
          expect(subject).to_not respond_to(:steps)
        end

        context "and quality is passed in options" do
          let(:options) do
            {format: format, quality: "30"}
          end

          it "sets the quality" do
            step = subject.steps[0]
            expect(step.name).to eq(:encode)
            expect(step.arguments).to eq([format, "-quality 30"])
          end
        end
      end

      context "and image has jpeg format" do
        let(:alchemy_picture) do
          build(:alchemy_picture, image_file: fixture_file_upload("image3.jpeg"))
        end

        it "does not convert the picture format" do
          expect(subject).to_not respond_to(:steps)
        end

        context "and quality is passed in options" do
          let(:options) do
            {format: format, quality: "30"}
          end

          it "sets the quality" do
            step = subject.steps[0]
            expect(step.name).to eq(:encode)
            expect(step.arguments).to eq([format, "-quality 30"])
          end
        end
      end

      context "and image has webp format" do
        let(:image_file) do
          fixture_file_upload("image5.webp")
        end

        let(:alchemy_picture) do
          build(:alchemy_picture, image_file: image_file, image_file_format: "webp")
        end

        let(:options) do
          {format: format}
        end

        it "converts the picture into #{format}" do
          step = subject.steps[0]
          expect(step.name).to eq(:encode)
          expect(step.arguments).to eq([format, "-quality 85"])
        end

        context "and quality is passed in options" do
          let(:options) do
            {format: format, quality: "30"}
          end

          it "sets the quality as well" do
            step = subject.steps[0]
            expect(step.name).to eq(:encode)
            expect(step.arguments).to eq([format, "-quality 30"])
          end
        end
      end
    end
  end

  context "when webp format is requested" do
    let(:options) do
      {format: "webp"}
    end

    context "and the image file format is not WebP" do
      it "converts image into webp and sets the default quality" do
        step = subject.steps[0]
        expect(step.name).to eq(:encode)
        expect(step.arguments).to eq(["webp", "-quality 85"])
      end

      context "but quality is passed" do
        let(:options) do
          {format: "webp", quality: "30"}
        end

        it "converts with given quality" do
          step = subject.steps[0]
          expect(step.name).to eq(:encode)
          expect(step.arguments).to eq(["webp", "-quality 30"])
        end
      end
    end

    context "and image already has webp format" do
      let(:image_file) do
        fixture_file_upload("image5.webp")
      end

      let(:alchemy_picture) do
        build(:alchemy_picture, image_file: image_file, image_file_format: "webp")
      end

      it "does not convert the picture format" do
        expect(subject).to_not respond_to(:steps)
      end

      context "and quality is passed in options" do
        let(:options) do
          {format: "webp", quality: "30"}
        end

        it "converts to given quality" do
          step = subject.steps[0]
          expect(step.name).to eq(:encode)
          expect(step.arguments).to eq(["webp", "-quality 30"])
        end
      end
    end
  end
end
