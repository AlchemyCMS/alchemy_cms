# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::ElementSerializer do
  subject { described_class.new(element).to_json }

  let(:element) { create(:alchemy_element) }

  it "includes all attributes" do
    json = JSON.parse(subject)
    expect(json).to eq(
      "created_at" => element.created_at.as_json,
      "display_name" => element.display_name_with_preview_text,
      "id" => element.id,
      "ingredients" => [],
      "name" => element.name,
      "nested_elements" => [],
      "page_id" => element.page.id,
      "page_version_id" => element.page_version_id,
      "position" => 1,
      "tag_list" => [],
      "updated_at" => element.updated_at.as_json
    )
  end

  context "with tags" do
    let(:element) { create(:alchemy_element, name: "article", tag_list: "red, yellow") }

    it "serializes the tags from the cache without a tag query" do
      reloaded = Alchemy::Element.find(element.id)
      tag_queries = 0
      sub = ActiveSupport::Notifications.subscribe("sql.active_record") do |*args|
        payload = args.last
        next if payload[:cached]
        tag_queries += 1 if /FROM ["`]?gutentag_(tags|taggings)["`]?/i.match?(payload[:sql])
      end
      json = JSON.parse(described_class.new(reloaded).to_json)
      ActiveSupport::Notifications.unsubscribe(sub)
      expect(json["tag_list"]).to eq(%w[red yellow])
      expect(tag_queries).to eq(0)
    end
  end
end
