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
    let(:sizes) { {small: "100x100", large: "800x800"} }

    before do
      stub_const("Alchemy::Picture::THUMBNAIL_SIZES", sizes)
      allow(described_class).to receive(:process_thumb)
    end

    it "calls process_thumb for each thumbnail size" do
      described_class.generate_thumbs!(attachable)
      sizes.values.each do |size|
        expect(described_class).to have_received(:process_thumb).with(attachable, size: size, flatten: true)
      end
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
