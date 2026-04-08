# frozen_string_literal: true

require "rails_helper"
require "alchemy/tasks/tidy"

RSpec.describe Alchemy::Tidy do
  describe ".remove_duplicate_legacy_urls" do
    let(:page) { create(:alchemy_page) }

    it "removes duplicate legacy URLs keeping the latest" do
      duplicate = Alchemy::LegacyPageUrl.create!(page: page, urlname: "my-page")
      original = Alchemy::LegacyPageUrl.create!(page: page, urlname: "my-page")

      described_class.remove_duplicate_legacy_urls

      expect(Alchemy::LegacyPageUrl.where(id: original.id)).to exist
      expect(Alchemy::LegacyPageUrl.where(id: duplicate.id)).not_to exist
    end

    it "does not remove unique legacy URLs" do
      original = Alchemy::LegacyPageUrl.create!(page: page, urlname: "my-page")
      other_original = Alchemy::LegacyPageUrl.create!(page: page, urlname: "my-other-page")

      described_class.remove_duplicate_legacy_urls

      expect(Alchemy::LegacyPageUrl.where(id: [original.id, other_original.id]).count).to eq(2)
    end

    it "removes all duplicates when more than two exist" do
      duplicate_one = Alchemy::LegacyPageUrl.create!(page: page, urlname: "my-page")
      duplicate_two = Alchemy::LegacyPageUrl.create!(page: page, urlname: "my-page")
      original = Alchemy::LegacyPageUrl.create!(page: page, urlname: "my-page")

      described_class.remove_duplicate_legacy_urls

      expect(Alchemy::LegacyPageUrl.where(id: original.id)).to exist
      expect(Alchemy::LegacyPageUrl.where(id: [duplicate_one.id, duplicate_two.id]).count).to eq(0)
    end

    it "handles duplicates across different pages" do
      other_page = create(:alchemy_page)
      original = Alchemy::LegacyPageUrl.create!(page: page, urlname: "my-page")
      other_original = Alchemy::LegacyPageUrl.create!(page: other_page, urlname: "my-page")

      described_class.remove_duplicate_legacy_urls

      expect(Alchemy::LegacyPageUrl.where(id: [original.id, other_original.id]).count).to eq(2)
    end
  end
end
