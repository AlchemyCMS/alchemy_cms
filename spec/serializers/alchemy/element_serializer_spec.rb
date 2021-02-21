# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::ElementSerializer do
  subject do
    JSON.parse(described_class.new(element, scope: current_ability).to_json)
  end

  let(:element) { create(:alchemy_element) }
  let(:current_ability) { Alchemy::Permissions.new(user) }

  context "for normal users" do
    let(:user) { build_stubbed(:alchemy_dummy_user) }

    it "includes all attributes" do
      is_expected.to eq(
        "content_ids" => [],
        "created_at" => element.created_at.strftime("%FT%T.%LZ"),
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

    it "excludes admin relevant attributes" do
      is_expected.to_not have_key("folded")
      is_expected.to_not have_key("public")
      is_expected.to_not have_key("display_name")
      is_expected.to_not have_key("preview_text")
      is_expected.to_not have_key("contents")
      is_expected.to have_key("ingredients")
      is_expected.to have_key("content_ids")
      is_expected.not_to have_key("has_validations")
    end
  end

  context "for admin users" do
    let(:user) { build_stubbed(:alchemy_dummy_user, :as_admin) }

    it "includes admin relevant attributes" do
      is_expected.to have_key("folded")
      is_expected.to have_key("public")
      is_expected.to have_key("display_name")
      is_expected.to have_key("preview_text")
      is_expected.to have_key("contents")
      is_expected.to_not have_key("ingredients")
      is_expected.to_not have_key("content_ids")
      is_expected.to have_key("has_validations")
      is_expected.to have_key("nestable_elements")
    end
  end
end
