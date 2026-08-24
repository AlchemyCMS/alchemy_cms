# frozen_string_literal: true

require "rails_helper"
require Alchemy::Engine.root.join("db", "migrate", "20260820120000_add_cached_tag_list_to_taggables.rb").to_s

RSpec.describe AddCachedTagListToTaggables do
  describe "#backfill" do
    it "populates cached_tag_list from existing taggings" do
      element = create(:alchemy_element, name: "article", tag_list: "red, yellow")
      # Simulate a row that predates the maintenance callback.
      element.update_column(:cached_tag_list, "[]")

      described_class.new.send(:backfill)

      expect(element.reload.cached_tag_list).to eq(%w[red yellow])
    end

    it "leaves untagged rows at the empty default" do
      element = create(:alchemy_element, name: "article")

      described_class.new.send(:backfill)

      expect(element.reload.cached_tag_list).to eq([])
    end
  end
end
