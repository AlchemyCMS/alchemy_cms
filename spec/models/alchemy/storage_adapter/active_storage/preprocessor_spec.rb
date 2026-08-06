require "rails_helper"

RSpec.describe Alchemy::StorageAdapter::ActiveStorage::Preprocessor, if: Alchemy.storage_adapter.active_storage? do
  let(:attachable) { double("attachable") }
  let(:preprocessor) { described_class.new(attachable) }

  describe "#call" do
    before do
      allow(Alchemy).to receive_message_chain(:config, :get).with(:preprocess_image_resize).and_return(max_image_size)
      allow(described_class).to receive(:process_thumb)
    end

    context "when preprocess_image_resize is set" do
      let(:max_image_size) { "1000x1000>" }

      it "calls process_thumb with the correct size" do
        preprocessor.call
        expect(described_class).to have_received(:process_thumb).with(attachable, size: "1000x1000>")
      end
    end

    context "when preprocess_image_resize is not set" do
      let(:max_image_size) { nil }

      it "does not call process_thumb" do
        preprocessor.call
        expect(described_class).not_to have_received(:process_thumb)
      end
    end
  end

  describe ".generate_thumbs!" do
    let(:blob) { instance_double(ActiveStorage::Blob) }
    let(:image_file) { double("image_file", blob: blob) }
    let(:picture) { double("picture", image_file: image_file, image_file_extension: "png") }

    before do
      stub_const("Alchemy::Picture::THUMBNAIL_SIZES", {
        small: "80x60",
        medium: "160x120",
        large: "240x180"
      })
      allow(ActiveStorage::TransformJob).to receive(:perform_later)
    end

    it "enqueues a TransformJob for each thumbnail size" do
      described_class.generate_thumbs!(picture)
      expect(ActiveStorage::TransformJob).to have_received(:perform_later).exactly(3).times
    end

    it "enqueues the medium thumbnail with the same transformations the archive requests" do
      described_class.generate_thumbs!(picture)
      expect(ActiveStorage::TransformJob).to have_received(:perform_later).with(
        blob,
        {resize_to_limit: [160, 120, {sharpen: false}], format: "png", saver: {quality: 85}}
      )
    end
  end

  describe ".process_thumb" do
    let(:options) { {size: "100x100"} }
    let(:processing_options) { {resize_to_limit: [100, 100]} }

    before do
      allow(Alchemy::DragonflyToImageProcessing).to receive(:call).with(options).and_return(processing_options)
      allow(attachable).to receive(:variant)
    end

    it "calls variant on the attachable with processed options" do
      described_class.process_thumb(attachable, options)
      expect(attachable).to have_received(:variant).with(:thumb, **processing_options, preprocessed: true)
    end
  end
end
