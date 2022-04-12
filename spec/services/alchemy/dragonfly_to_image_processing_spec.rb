# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::DragonflyToImageProcessing do
  subject { described_class.call(options) }

  context "if crop size options are given" do
    let(:options) do
      {
        crop: true,
        crop_from: "0x0",
        size: "200x100",
        crop_size: "2000x1000",
      }
    end

    it "crops then resizes" do
      is_expected.to eq(
        {
          crop: [0, 0, 2000, 1000],
          resize_to_limit: [200, 100, { sharpen: false }],
          saver: { quality: 85 },
        }
      )
    end

    context "if sharpen is enabled" do
      let(:options) do
        {
          crop: true,
          crop_from: "0x0",
          size: "200x100",
          crop_size: "2000x1000",
          sharpen: true,
        }
      end

      it "enables sharpen" do
        is_expected.to eq(
          {
            crop: [0, 0, 2000, 1000],
            resize_to_limit: [200, 100, {}],
            saver: { quality: 85 },
          }
        )
      end
    end
  end

  context "if no crop size options are given" do
    context "Size option contains trailing >" do
      let(:options) { { size: "100x100>" } }

      it "uses resize_to_limit" do
        is_expected.to eq(
          {
            resize_to_limit: [100, 100, { sharpen: false }],
            saver: { quality: 85 },
          }
        )
      end
    end

    context "Size option contains trailing ^" do
      let(:options) { { size: "100x100^" } }

      it "uses resize_to_fit" do
        is_expected.to eq(
          {
            resize_to_fit: [100, 100, { sharpen: false }],
            saver: { quality: 85 },
          }
        )
      end
    end

    context "Size option contains trailing #" do
      let(:options) { { size: "100x100#" } }

      it "uses resize_to_fill with a center gravity" do
        is_expected.to eq(
          {
            resize_to_fill: [100, 100, { sharpen: false }],
            saver: { quality: 85 },
          }
        )
      end
    end

    context "Size option contains no operator" do
      let(:options) { { size: "100x100" } }

      it "uses resize_to_limit" do
        is_expected.to eq(
          {
            resize_to_limit: [100, 100, { sharpen: false }],
            saver: { quality: 85 },
          }
        )
      end

      context "but options[:crop] is true" do
        let(:options) { { size: "100x100", crop: true } }

        it "uses resize_to_fill with a center gravity" do
          is_expected.to eq(
            {
              resize_to_fill: [100, 100, { sharpen: false }],
              saver: { quality: 85 },
            }
          )
        end
      end
    end

    context "if sharpen is enabled" do
      let(:options) { { size: "100x100", sharpen: true } }

      it "enables sharpen" do
        is_expected.to eq(
          {
            resize_to_limit: [100, 100, {}],
            saver: { quality: 85 },
          }
        )
      end
    end

    context "Size option is nil" do
      let(:options) { {} }

      it "just contains default quality option" do
        is_expected.to eq({ saver: { quality: 85 } })
      end

      context "if quality is given" do
        let(:options) { { quality: 15 } }

        it "contains given quality option" do
          is_expected.to eq({ saver: { quality: 15 } })
        end
      end
    end

    context "Format option is given" do
      let(:options) { { format: "webp" } }

      it "contains the format option" do
        is_expected.to eq(
          {
            format: "webp",
            saver: { quality: 85 },
          }
        )
      end
    end

    context "Format option is not given" do
      let(:options) { {} }

      context "and the image output format is configured to be original" do
        before do
          stub_alchemy_config(:image_output_format, "original")
        end

        it "does not contain the format option" do
          is_expected.to eq(
            {
              saver: { quality: 85 },
            }
          )
        end
      end

      context "and the image output format is configured to webp" do
        before do
          stub_alchemy_config(:image_output_format, "webp")
        end

        it "does not contain the format option" do
          is_expected.to eq(
            {
              saver: { quality: 85 },
              format: "webp",
            }
          )
        end
      end
    end
  end
end
