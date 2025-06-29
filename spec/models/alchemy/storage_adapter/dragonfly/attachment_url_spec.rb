# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::StorageAdapter::Dragonfly::AttachmentUrl, if: Alchemy.storage_adapter.dragonfly? do
  let(:attachment) { create(:alchemy_attachment) }

  subject { described_class.new(attachment).call(options) }

  let(:options) { {} }

  it "returns the url to show the file" do
    is_expected.to match(/\/attachment\/\d+\/show\.png/)
  end

  context "without a file" do
    before do
      allow(attachment).to receive(:file) { nil }
    end

    it "returns nil" do
      is_expected.to be_nil
    end
  end

  context "with download option" do
    let(:options) { {download: true} }

    it "returns the url to download the file" do
      is_expected.to match(/\/attachment\/\d+\/download\.png/)
    end
  end
end
