require "rails_helper"

RSpec.describe Alchemy::StorageAdapter::Dragonfly::Preprocessor, if: Alchemy.storage_adapter.dragonfly? do
  let(:image_file) { double("image_file") }
  let(:preprocessor) { described_class.new(image_file) }

  describe "#call" do
    before do
      allow(image_file).to receive(:thumb!)
      allow(image_file).to receive(:auto_orient!)
    end

    context "when preprocess_image_resize is set" do
      before do
        allow(Alchemy.config).to receive(:get).with(:preprocess_image_resize).and_return("1000x1000>")
      end

      it "calls thumb! with the resize option" do
        preprocessor.call
        expect(image_file).to have_received(:thumb!).with("1000x1000>")
      end

      it "calls auto_orient! on the image file" do
        preprocessor.call
        expect(image_file).to have_received(:auto_orient!)
      end
    end

    context "when preprocess_image_resize is not set" do
      before do
        allow(Alchemy.config).to receive(:get).with(:preprocess_image_resize).and_return(nil)
      end

      it "does not call thumb!" do
        preprocessor.call
        expect(image_file).not_to have_received(:thumb!)
      end

      it "still calls auto_orient! on the image file" do
        preprocessor.call
        expect(image_file).to have_received(:auto_orient!)
      end
    end
  end
end
