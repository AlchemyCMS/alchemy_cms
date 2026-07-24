# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::GenerateThumbnails do
  # Adapter-agnostic count of persisted thumbnail artifacts.
  # ActiveStorage tracks processed variants in variant records, while
  # Dragonfly persists them as Alchemy::PictureThumb records.
  def thumbnail_count
    if Alchemy.storage_adapter.active_storage?
      ActiveStorage::VariantRecord.count
    else
      Alchemy::PictureThumb.count
    end
  end

  describe ".pictures" do
    let!(:picture) { create(:alchemy_picture) }

    before do
      # Dragonfly generates the archive thumbnails on create,
      # so start from a clean slate to assert regeneration on both adapters.
      Alchemy::PictureThumb.delete_all
    end

    it "generates the archive thumbnails for all pictures" do
      expect { described_class.pictures }.to change { thumbnail_count }
    end

    it "yields each processed picture for progress reporting" do
      expect { |probe| described_class.pictures(&probe) }.to yield_with_args(picture)
    end
  end

  describe ".ingredients" do
    let(:picture) { create(:alchemy_picture) }
    let!(:ingredient) { create(:alchemy_ingredient_picture, related_object: picture) }

    it "generates thumbnails for published picture ingredients" do
      expect { described_class.ingredients }.to change { thumbnail_count }
    end

    it "yields each processed ingredient for progress reporting" do
      expect { |probe| described_class.ingredients(&probe) }.to yield_with_args(ingredient)
    end

    context "when the picture ingredient defines a srcset" do
      before do
        allow_any_instance_of(Alchemy::Ingredients::Picture).to receive(:settings).and_return(
          ActiveSupport::HashWithIndifferentAccess.new(size: "1200x480", srcset: ["80x60"])
        )
      end

      it "generates the srcset variants" do
        expect { described_class.ingredients }.to change { thumbnail_count }
      end
    end

    context "when restricted to element names that do not match" do
      it "does not generate thumbnails for other elements" do
        expect {
          described_class.ingredients(element_names: ["non_existent_element"])
        }.not_to change { thumbnail_count }
      end
    end

    context "when the picture is not convertible (e.g. an svg)" do
      before do
        allow_any_instance_of(Alchemy::Picture).to receive(:has_convertible_format?).and_return(false)
      end

      it "does not generate thumbnails" do
        expect { described_class.ingredients }.not_to change { thumbnail_count }
      end
    end

    context "when configured to convert images to webp" do
      before { stub_alchemy_config(image_output_format: "webp") }

      it "still generates thumbnails for the convertible source" do
        expect { described_class.ingredients }.to change { thumbnail_count }
      end

      if Alchemy.storage_adapter.active_storage?
        it "generates them in the configured webp format" do
          described_class.ingredients
          content_types = ActiveStorage::VariantRecord.all.map { |record| record.image.blob.content_type }
          expect(content_types).to include("image/webp")
        end
      end
    end

    if Alchemy.storage_adapter.active_storage?
      context "when a variant fails to process" do
        before do
          allow(Alchemy::DragonflyToImageProcessing).to receive(:call).and_raise("boom")
        end

        it "reports the error and keeps going" do
          expect(Alchemy::ErrorTracking.notification_handler).to receive(:call).at_least(:once)
          expect { described_class.ingredients }.not_to raise_error
        end
      end
    end
  end
end
