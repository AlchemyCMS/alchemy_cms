# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::IngredientPreloaders::PicturePreloader do
  describe ".call" do
    context "with an empty array" do
      it "does not call the storage adapter" do
        expect(Alchemy.storage_adapter).not_to receive(:preload_picture_associations)
        described_class.call([])
      end
    end

    context "with nil" do
      it "does not call the storage adapter" do
        expect(Alchemy.storage_adapter).not_to receive(:preload_picture_associations)
        described_class.call(nil)
      end
    end

    context "with pictures" do
      let(:pictures) { [build(:alchemy_picture)] }

      it "delegates to the storage adapter" do
        expect(Alchemy.storage_adapter).to receive(:preload_picture_associations).with(pictures)
        described_class.call(pictures)
      end

      it "preloads descriptions" do
        allow(ActiveRecord::Associations::Preloader).to receive(:new).and_call_original
        expect(ActiveRecord::Associations::Preloader).to receive(:new).with(
          records: pictures,
          associations: :descriptions
        ).and_call_original
        described_class.call(pictures)
      end
    end
  end
end
