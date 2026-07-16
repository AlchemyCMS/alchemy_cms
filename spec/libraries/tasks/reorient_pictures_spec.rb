# frozen_string_literal: true

require "rails_helper"
require "alchemy/tasks/reorient_pictures"

RSpec.describe Alchemy::ReorientPictures, if: Alchemy.storage_adapter.dragonfly? do
  before { Alchemy::Shell.silence! }
  after { Alchemy::Shell.verbose! }

  describe ".call" do
    context "for a master that still carries an EXIF orientation" do
      let(:picture) { Alchemy::Picture.last }

      before do
        # Skip the upload preprocessor so the master keeps its EXIF orientation
        # instead of being baked, simulating a legacy upload.
        allow_any_instance_of(Alchemy::StorageAdapter::Dragonfly::Preprocessor)
          .to receive(:call)
        # 100x200 stored, EXIF orientation 6, i.e. displayed rotated as 200x100
        create(:alchemy_picture, image_file: fixture_file_upload("exif-orientation-6.jpg"))
      end

      it "returns the affected picture ids" do
        expect(described_class.call).to eq([picture.id])
      end

      it "prints a progress indicator" do
        Alchemy::Shell.verbose!
        expect { described_class.call }.to output(/o/).to_stdout
      end

      it "bakes the orientation into the master and normalizes its dimensions" do
        expect { described_class.call }
          .to change { picture.reload.image_file_width }.from(100).to(200)
          .and change { picture.reload.image_file_height }.from(200).to(100)
      end

      it "clears the stale cached thumbs" do
        stale = picture.thumbs.create!(signature: "stale", uid: "pictures/#{picture.id}/stale/image.webp")
        described_class.call
        expect(Alchemy::PictureThumb.where(id: stale.id)).not_to exist
      end

      context "when the picture is used in an element" do
        before do
          create(:alchemy_ingredient_picture, related_object: picture)
        end

        it "invalidates the element and page caches" do
          expect {
            described_class.call
          }.to have_enqueued_job(Alchemy::InvalidateElementsCacheJob)
            .with("Alchemy::Picture", picture.id)
            .once
        end

        it "regenerates the frontend variants used by the ingredients" do
          expect_any_instance_of(Alchemy::Ingredients::Picture)
            .to receive(:picture_url).at_least(:once)
          described_class.call
        end
      end
    end

    context "when limited to specific picture ids" do
      let(:other) { Alchemy::Picture.first }
      let(:picture) { Alchemy::Picture.last }

      before do
        allow_any_instance_of(Alchemy::StorageAdapter::Dragonfly::Preprocessor)
          .to receive(:call)
        create(:alchemy_picture, image_file: fixture_file_upload("exif-orientation-6.jpg"))
        create(:alchemy_picture, image_file: fixture_file_upload("exif-orientation-6.jpg"))
      end

      it "only processes the given pictures" do
        expect(described_class.call(picture_ids: [picture.id])).to eq([picture.id])
        expect(other.reload.image_file_width).to eq(100)
        expect(picture.reload.image_file_width).to eq(200)
      end
    end

    context "for a master that is already upright" do
      let(:picture) { Alchemy::Picture.last }

      before do
        create(:alchemy_picture, image_file: fixture_file_upload("500x500.png"))
      end

      it "leaves it untouched" do
        expect { described_class.call }.not_to change { picture.reload.updated_at }
      end
    end

    context "when a variant can not be regenerated" do
      let(:picture) { Alchemy::Picture.last }

      before do
        allow_any_instance_of(Alchemy::StorageAdapter::Dragonfly::Preprocessor)
          .to receive(:call)
        create(:alchemy_picture, image_file: fixture_file_upload("exif-orientation-6.jpg"))
        create(:alchemy_ingredient_picture, related_object: picture)
        allow_any_instance_of(Alchemy::Ingredients::Picture)
          .to receive(:picture_url).and_raise("boom")
      end

      it "logs the error and still bakes the master" do
        expect { described_class.call }.not_to raise_error
        expect(picture.reload.image_file_width).to eq(200)
      end
    end

    context "when the master file is missing from the datastore" do
      before do
        allow_any_instance_of(Alchemy::StorageAdapter::Dragonfly::Preprocessor)
          .to receive(:call)
        create(:alchemy_picture, image_file: fixture_file_upload("exif-orientation-6.jpg"))
        allow(described_class).to receive(:orientation_of)
          .and_raise(Dragonfly::Job::Fetch::NotFound, "uid not found")
      end

      it "skips the picture and does not raise" do
        expect { described_class.call }.not_to raise_error
        expect(described_class.call).to eq([])
      end
    end

    context "when not using the Dragonfly storage adapter" do
      before { allow(Alchemy.storage_adapter).to receive(:dragonfly?).and_return(false) }

      it "does nothing" do
        expect(described_class.call).to eq([])
      end
    end

    it "restores the loggers after running" do
      dragonfly_logger = Dragonfly.logger
      active_job_logger = ActiveJob::Base.logger
      described_class.call
      expect(Dragonfly.logger).to eq(dragonfly_logger)
      expect(ActiveJob::Base.logger).to eq(active_job_logger)
    end
  end

  describe ".report (dry run)" do
    let(:picture) { Alchemy::Picture.last }

    before do
      allow_any_instance_of(Alchemy::StorageAdapter::Dragonfly::Preprocessor)
        .to receive(:call)
      create(:alchemy_picture, image_file: fixture_file_upload("exif-orientation-6.jpg"))
    end

    it "returns the affected picture ids" do
      expect(described_class.report).to eq([picture.id])
    end

    it "prints the ids to reorient" do
      Alchemy::Shell.verbose!
      expect { described_class.report }.to output(/PICTURE_IDS=#{picture.id}/).to_stdout
    end

    it "does not change the master" do
      expect { described_class.report }.not_to change { picture.reload.image_file_width }
    end

    it "does not clear cached thumbs" do
      thumb = picture.thumbs.create!(signature: "sig", uid: "pictures/#{picture.id}/sig/image.webp")
      described_class.report
      expect(Alchemy::PictureThumb.where(id: thumb.id)).to exist
    end
  end
end
