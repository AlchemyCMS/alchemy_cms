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

  context "file link" do
    it "has a file select" do
      expect(page).to have_selector("select[name=file_link] option")
    end

    context "tab selected" do
      let(:is_selected) { true }

      it "has a selected value" do
        expect(page).to have_selector("select[name=file_link] option[selected='selected']")
      end
    end

    context "tab not selected" do
      it "has a selected value" do
        expect(page).to_not have_selector("select[name=file_link] option[selected='selected']")
      end
    end
  end
end
