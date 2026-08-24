# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Taggable do
  # Alchemy::Element is a taggable model that has the cached_tag_list column.
  describe "cached_tag_list maintenance" do
    it "caches the tag names on save" do
      element = create(:alchemy_element, name: "article", tag_list: "red, yellow")
      expect(element.reload.cached_tag_list).to eq(%w[red yellow])
    end

    it "updates the cache when tags change" do
      element = create(:alchemy_element, name: "article", tag_list: "red, yellow")
      element.update!(tag_list: "green")
      expect(element.reload.cached_tag_list).to eq(%w[green])
    end

    it "clears the cache when all tags are removed" do
      element = create(:alchemy_element, name: "article", tag_list: "red, yellow")
      element.update!(tag_list: "")
      expect(element.reload.cached_tag_list).to eq([])
    end

    it "updates the cache when a tag is replaced" do
      element = create(:alchemy_element, name: "article", tag_list: "red, yellow")
      Alchemy::Tag.replace(Alchemy::Tag.find_by(name: "red"), Alchemy::Tag.create!(name: "blue"))
      expect(element.reload.cached_tag_list).to match_array(%w[blue yellow])
    end

    it "does not query the tags when saving an untagged record" do
      element = create(:alchemy_element, name: "article")
      tag_queries = 0
      sub = ActiveSupport::Notifications.subscribe("sql.active_record") do |*args|
        payload = args.last
        next if payload[:cached]
        tag_queries += 1 if /gutentag_(tags|taggings)/i.match?(payload[:sql])
      end
      element.update!(public: false)
      ActiveSupport::Notifications.unsubscribe(sub)
      expect(tag_queries).to eq(0)
    end
  end
end
