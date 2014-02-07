require 'spec_helper'

describe 'Page editing feature', js: true do
  let(:a_page) { FactoryGirl.create(:page) }

  before { authorize_as_admin }

  context "in preview mode" do
    it "the menubar does not render on the page" do
      visit alchemy.edit_admin_page_path(a_page)
      within_frame('alchemyPreviewWindow') do
        a_page.should_not have_selector('#alchemy_menubar')
      end
    end
  end
end
