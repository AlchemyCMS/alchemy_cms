# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::PageSerializer do
  subject do
    described_class.new(page, scope: Alchemy::Permissions.new(user)).to_json
  end

  let(:page) { build_stubbed(:alchemy_page) }

  context "for guest user" do
    let(:user) { nil }

    it "includes public attributes" do
      json = JSON.parse(subject)
      expect(json).to match(
        "id" => page.id,
        "name" => page.name,
        "urlname" => page.urlname,
        "page_layout" => page.page_layout,
        "title" => page.title,
        "language_code" => page.language_code,
        "meta_keywords" => page.meta_keywords,
        "meta_description" => page.meta_description,
        "tag_list" => page.tag_list,
        "created_at" => an_instance_of(String),
        "updated_at" => an_instance_of(String),
        "status" => page.status.transform_keys(&:to_s),
        "url_path" => page.url_path,
        "parent_id" => page.parent_id,
        "elements" => []
      )
    end
  end

  context "for admin user" do
    let(:user) { build_stubbed(:alchemy_dummy_user, :as_author) }

    it "includes all attributes" do
      json = JSON.parse(subject)
      expect(json).to match(
        "id" => page.id,
        "name" => page.name,
        "urlname" => page.urlname,
        "page_layout" => page.page_layout,
        "title" => page.title,
        "language_code" => page.language_code,
        "meta_keywords" => page.meta_keywords,
        "meta_description" => page.meta_description,
        "tag_list" => page.tag_list,
        "created_at" => an_instance_of(String),
        "updated_at" => an_instance_of(String),
        "status" => page.status.transform_keys(&:to_s),
        "url_path" => page.url_path,
        "parent_id" => page.parent_id,
        "elements" => [],
        "site" => {
          "id" => page.site.id,
          "name" => "Default Site"
        },
        "language" => {
          "id" => page.language_id,
          "name" => "Your Language"
        }
      )
    end
  end
end
