require 'spec_helper'

describe "Link overlay" do

  before do
    authorize_user(:as_admin)
  end

  context "GUI" do

    it "has a tab for linking internal pages" do
      visit link_admin_pages_path
      within('#overlay_tabs') { expect(page).to have_content('Internal')}
    end

    it "has a tab for linking external pages" do
      visit link_admin_pages_path
      within('#overlay_tabs') { expect(page).to have_content('External')}
    end

    it "has a tab for linking files" do
      visit link_admin_pages_path
      within('#overlay_tabs') { expect(page).to have_content('File')}
    end

  end

  context "linking internal pages" do

    let(:lang_root) do
      FactoryGirl.create(:language_root_page)
    end

    before do
      public_page = FactoryGirl.create(:public_page, :parent_id => lang_root.id)
      public_page_2 = FactoryGirl.create(:public_page, :parent_id => lang_root.id)
    end

    it "should have a tree of internal pages" do
      visit link_admin_pages_path
      expect(page).to have_selector('ul#sitemap li a')
    end

    it "should not have a link for pages that redirect to external" do
      redirect = FactoryGirl.create(:page, :parent_id => lang_root.id, :name => 'Google', :urlname => 'http://www.google.com')
      allow_any_instance_of(Alchemy::Page).to receive(:definition).and_return({'redirects_to_external' => true})
      visit link_admin_pages_path
      expect(page).not_to have_selector('ul#sitemap li div[name="/http-www-google-com"] a')
      allow_any_instance_of(Alchemy::Page).to receive(:definition).and_call_original
    end

  end

end
