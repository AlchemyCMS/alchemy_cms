# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::ElementSerializer do
  subject { described_class.new(element).to_json }

  let(:element) { create(:alchemy_element) }

  it "includes all attributes" do
    json = JSON.parse(subject)
    expect(json).to eq(
      "content_ids" => [],
      "created_at" => element.created_at.strftime("%FT%T.%LZ"),
      "display_name" => element.display_name_with_preview_text,
      "dom_id" => element.dom_id,
      "id" => element.id,
      "ingredients" => [],
      "name" => element.name,
      "nested_elements" => [],
      "page_id" => element.page.id,
      "page_version_id" => element.page_version_id,
      "position" => 1,
      "tag_list" => [],
      "updated_at" => element.updated_at.strftime("%FT%T.%LZ"),
    )
  end
end
