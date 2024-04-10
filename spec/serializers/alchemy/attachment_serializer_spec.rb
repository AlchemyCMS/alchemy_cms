# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::AttachmentSerializer do
  subject { described_class.new(attachment).to_json }

  let(:attachment) { build_stubbed(:alchemy_attachment) }

  it "includes all attributes" do
    json = JSON.parse(subject)
    expect(json).to eq(
      "id" => attachment.id,
      "name" => attachment.name,
      "file_name" => attachment.file_name,
      "file_mime_type" => attachment.file_mime_type,
      "file_size" => attachment.file_size,
      "icon_css_class" => attachment.icon_css_class,
      "tag_list" => attachment.tag_list,
      "created_at" => attachment.created_at.as_json,
      "updated_at" => attachment.updated_at.as_json,
      "url" => "/attachment/#{attachment.id}/download/#{attachment.file_name}"
    )
  end
end
