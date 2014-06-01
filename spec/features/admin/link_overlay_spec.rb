require 'spec_helper'

describe "Link overlay" do

  before do
    authorize_as_admin
  end

  context "GUI" do

    it "has a tab for linking internal pages" do
      visit link_admin_pages_path
      within('#overlay_tabs') { page.should have_content('Internal')}
    end

    it "has a tab for linking external pages" do
      visit link_admin_pages_path
      within('#overlay_tabs') { page.should have_content('External')}
    end

    it "has a tab for linking files" do
      visit link_admin_pages_path
      within('#overlay_tabs') { page.should have_content('File')}
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
      page.should have_selector('ul#sitemap li a')
    end

    it "should not have a link for pages that redirect to external" do
      redirect = FactoryGirl.create(:page, :parent_id => lang_root.id, :name => 'Google', :urlname => 'http://www.google.com')
      Alchemy::Page.any_instance.stub(:definition).and_return({'redirects_to_external' => true})
      visit link_admin_pages_path
      page.should_not have_selector('ul#sitemap li div[name="/http-www-google-com"] a')
      Alchemy::Page.any_instance.unstub(:definition)
    end

  end

end
