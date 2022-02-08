# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::PictureVariant do
  let(:image_file) do
    File.new(File.expand_path("../../fixtures/500x500.png", __dir__))
  end

  let(:alchemy_picture) { build_stubbed(:alchemy_picture, image_file: image_file) }

  it_behaves_like "has image transformations" do
    let(:picture) { described_class.new(alchemy_picture) }
  end

  subject { described_class.new(alchemy_picture, options).image }

  let(:options) { Hash.new }

  context "when no image is present" do
    let(:alchemy_picture) { nil }

    it "raises ArgumentError" do
      expect { subject }.to raise_error(ArgumentError)
    end
  end

  context "when a size is passed in" do
    let(:options) do
      { size: "120x160" }
    end

    it "resizes the image without upsampling it" do
      expect(subject.steps[0].arguments).to eq(["120x160>"])
    end

    context "but upsample set to true" do
      let(:options) do
        {
          size: "1600x1200",
          upsample: true,
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
          crop: true,
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
            crop: true,
          }
        end

        it "crops and resizes the picture" do
          expect(subject.steps[0].arguments).to eq(["-crop 123x44+0+0 -resize 160x120>"])
        end
      end
    end

    context "and crop is set to false" do
      let(:options) do
        {
          size: "160x120",
          crop: false,
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
            crop: false,
          }
        end

        it "does not crop the picture" do
          expect(subject.steps[0].arguments).to eq(["160x120>"])
        end
      end
    end

    context "with no height given" do
      let(:options) do
        { size: "40" }
      end

      it "resizes the image inferring the height" do
        expect(subject.steps[0].arguments).to eq(["40>"])
      end
    end

    context "with no width given" do
      let(:options) do
        { size: "x30" }
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
      { format: "gif" }
    end

    it "converts the format" do
      step = subject.steps[0]
      expect(step.name).to eq(:encode)
      expect(step.arguments).to include("gif")
    end

    context "but image has not a convertible format (svg)" do
      let(:image_file) do
        fixture_file_upload(
          File.expand_path("../../fixtures/icon.svg", __dir__),
          "image/svg+xml",
        )
      end

      it "does not convert the picture format" do
        expect(subject.job.steps.size).to eq(0)
      end
    end

    context "for an animated gif" do
      let(:options) do
        { format: "png" }
      end

      let(:image_file) do
        fixture_file_upload(
          File.expand_path("../../fixtures/animated.gif", __dir__),
          "image/gif",
        )
      end

      it "flattens the image." do
        step = subject.steps[0]
        expect(step.name).to eq(:encode)
        expect(step.arguments).to eq(["png", "-flatten"])
      end
    end
  end

  context "requesting a not allowed format" do
    let(:options) do
      { format: "zip" }
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
        { format: format }
      end

      context "and the image file format is not JPG" do
        it "sets the default quality" do
          step = subject.steps[0]
          expect(step.name).to eq(:encode)
          expect(step.arguments).to eq([format, "-quality 85"])
        end

        context "and quality is passed" do
          let(:options) do
            { format: format, quality: "30" }
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
          build_stubbed(:alchemy_picture, image_file: image_file, image_file_format: "jpg")
        end

        it "does not convert the picture format" do
          expect(subject).to_not respond_to(:steps)
        end

        context "and quality is passed in options" do
          let(:options) do
            { format: format, quality: "30" }
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
          build_stubbed(:alchemy_picture, image_file: image_file, image_file_format: "jpeg")
        end

        it "does not convert the picture format" do
          expect(subject).to_not respond_to(:steps)
        end

        context "and quality is passed in options" do
          let(:options) do
            { format: format, quality: "30" }
          end

          it "sets the quality" do
            step = subject.steps[0]
            expect(step.name).to eq(:encode)
            expect(step.arguments).to eq([format, "-quality 30"])
          end
        end
      end
    end
  end
end
