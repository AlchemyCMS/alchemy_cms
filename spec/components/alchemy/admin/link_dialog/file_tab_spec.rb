# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::LinkDialog::FileTab, type: :component do
  let!(:attachment) { create(:alchemy_attachment) }
  let(:url) { Alchemy::Engine.routes.url_helpers.download_attachment_path(id: attachment.id, name: attachment.slug) }

  let(:is_selected) { false }
  let(:link_title) { nil }
  let(:link_target) { nil }

  before do
    render_inline(described_class.new(url, is_selected: is_selected, link_title: link_title, link_target: link_target))
  end

  it_behaves_like "a link dialog tab", :file, "File"
  it_behaves_like "a link dialog - target select", :file

  it "has a file select" do
    expect(page).to have_selector("alchemy-attachment-select [name=file_link]")
  end

  context "with attachment found by url" do
    it "has value set" do
      expect(page).to have_selector("alchemy-attachment-select [value='#{url}']")
    end
  end

  context "with attachment not found by url" do
    let(:url) { Alchemy::Engine.routes.url_helpers.show_page_path(urlname: "foo") }

    it "has no value set" do
      expect(page).to_not have_selector("alchemy-attachment-select [value='#{url}']")
    end
  end
end
