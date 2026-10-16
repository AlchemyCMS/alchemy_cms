# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::IngredientPreloaders::AttachmentPreloader do
  describe ".call" do
    context "with an empty array" do
      it "does not call the storage adapter" do
        expect(Alchemy.storage_adapter).not_to receive(:preload_attachment_associations)
        described_class.call([])
      end
    end

    context "with nil" do
      it "does not call the storage adapter" do
        expect(Alchemy.storage_adapter).not_to receive(:preload_attachment_associations)
        described_class.call(nil)
      end
    end

    context "with attachments" do
      let(:attachments) { [build(:alchemy_attachment)] }

      it "delegates to the storage adapter" do
        expect(Alchemy.storage_adapter).to receive(:preload_attachment_associations).with(attachments)
        described_class.call(attachments)
      end
    end
  end
end
