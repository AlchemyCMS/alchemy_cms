# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::AttachmentSerializer do
  subject { described_class.new(attachment).to_json }

  let(:file) do
    Alchemy::Engine.root.join("lib", "alchemy", "test_support", "fixtures", "image.png")
  end

  let(:attachment) { create(:alchemy_attachment, file: file) }

  it "includes all attributes" do
    json = JSON.parse(subject)
    expect(json).to eq(
      "id" => attachment.id,
      "name" => "image",
      "file_name" => "image.png",
      "file_mime_type" => "image/png",
      "file_size" => attachment.file_size,
      "icon_css_class" => "file-image",
      "tag_list" => attachment.tag_list,
      "created_at" => attachment.created_at.as_json,
      "updated_at" => attachment.updated_at.as_json,
      "url" => "/attachment/#{attachment.id}/download/#{attachment.file_name}"
    )
  end
end
