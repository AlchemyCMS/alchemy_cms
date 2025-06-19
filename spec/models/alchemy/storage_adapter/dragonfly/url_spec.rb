# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::StorageAdapter::Dragonfly::Url, if: Alchemy.storage_adapter.dragonfly? do
  let(:image) { fixture_file_upload("image.png") }
  let(:picture) { create(:alchemy_picture, image_file: image) }

  subject { described_class.new(picture).call(options) }

  let(:options) { {} }

  it "returns the url to the image" do
    is_expected.to match(/\/pictures\/[a-zA-Z\d]+\/image\.png/)
  end

  context "when params are passed" do
    let(:options) do
      {
        page: 1,
        per_page: 10
      }
    end

    it "passes them to the URL" do
      is_expected.to match(/page=1/)
    end
  end

  context "with a processed variant" do
    let(:options) do
      {size: "10x10"}
    end

    it "returns the url to the thumbnail" do
      is_expected.to match(/\/pictures\/\d+\/.+\/image\.png/)
    end

    it "connects to writing database" do
      writing_role = ActiveRecord.writing_role
      expect(ActiveRecord::Base).to receive(:connected_to).with(role: writing_role)
      subject
    end
  end

  context "with format in options" do
    let(:options) do
      {format: "webp"}
    end

    it "adds format to url" do
      is_expected.to match(/\/image\.webp$/)
    end
  end
end
