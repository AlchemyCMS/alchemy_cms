# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Link overlay", type: :system do
  before do
    authorize_user(:as_admin)
  end

  context "GUI" do
    it "has a tab for linking internal pages" do
      visit link_admin_pages_path
      within('#overlay_tabs') { expect(page).to have_content('Internal') }
    end

    it "has a tab for linking external pages" do
      visit link_admin_pages_path
      within('#overlay_tabs') { expect(page).to have_content('External') }
    end

    it "has a tab for linking files" do
      visit link_admin_pages_path
      within('#overlay_tabs') { expect(page).to have_content('File') }
    end
  end

  context "linking internal pages", js: true do
    let(:lang_root) do
      create(:alchemy_page, :language_root)
    end

    before do
      create(:alchemy_page, :public, parent_id: lang_root.id)
      create(:alchemy_page, :public, parent_id: lang_root.id)
    end

    it "should have code to load a tree of internal pages" do
      visit link_admin_pages_path
      # Doesn't work, because the parent page sets the `dialog` variable in window:
      # expect(page).to have_selector('ul#sitemap li a')
      expect(page).to have_selector('div#page_selector_container div#sitemap-wrapper')
      expect(page).to have_selector('div#page_selector_container script')
    end
  end
end
