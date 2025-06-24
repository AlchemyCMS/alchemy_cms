# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::StorageAdapter::ActiveStorage::AttachmentUrl, if: Alchemy.storage_adapter.active_storage? do
  let(:attachment) { create(:alchemy_attachment) }

  subject { described_class.new(attachment).call(options) }

  let(:options) { {} }

  it "returns the url to show the file" do
    is_expected.to match(/\/attachment\/\d+\/show\.png/)
  end

  context "with download option" do
    let(:options) { {download: true} }

    it "returns the url to download the file" do
      is_expected.to match(/\/attachment\/\d+\/download\.png/)
    end
  end
end
