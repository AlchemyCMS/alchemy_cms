# frozen_string_literal: true

require 'spec_helper'

describe "Link overlay" do
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

    it "should not have a link for pages that redirect to external" do
      create(:alchemy_page, parent_id: lang_root.id, name: 'Google', urlname: 'http://www.google.com')
      allow_any_instance_of(Alchemy::Page).to receive(:definition) do
        {'redirects_to_external' => true}
      end
      visit link_admin_pages_path
      expect(page).not_to have_selector('ul#sitemap li div[name="/http-www-google-com"] a')
      allow_any_instance_of(Alchemy::Page).to receive(:definition).and_call_original
    end
  end
end
