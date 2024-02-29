# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::Pages::FileTab, type: :component do
  let!(:attachment) { create(:alchemy_attachment) }
  let(:url) { "/foo" }
  let(:selected_tab) { :foo }

  before do
    render_inline(described_class.new(url, selected_tab, nil, nil))
  end

  context "default configuration" do
    it "has a file select" do
      expect(page).to have_selector("select[name=file_link] option")
    end

    it "has a selected value" do
      expect(page).to_not have_selector("select option[selected='selected']")
    end
  end

  context "with selected value" do
    let(:url) { Alchemy::Engine.routes.url_helpers.download_attachment_path(id: attachment.id, name: attachment.slug) }

    context "tab selected" do
      let(:selected_tab) { :file }
      it "has a selected value" do
        expect(page).to have_selector("select option[selected='selected']")
      end
    end

    context "tab not selected" do
      it "has a selected value" do
        expect(page).to_not have_selector("select option[selected='selected']")
      end
    end
  end
end
