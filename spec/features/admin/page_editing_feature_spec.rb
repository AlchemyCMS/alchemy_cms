require 'spec_helper'

describe 'Page editing feature' do
  let(:a_page) { FactoryGirl.create(:public_page, visible: true) }

  before { authorize_as_admin }

  context "in preview frame" do
    it "the menubar does not render on the page" do
      visit alchemy.admin_page_path(a_page)
      page.should_not have_selector('#alchemy_menubar')
    end

    it "navigation links are not clickable" do
      visit alchemy.admin_page_path(a_page)
      within('#navigation') do
        page.should have_selector('a[href="javascript: void(0)"]')
      end
    end
  end
end
