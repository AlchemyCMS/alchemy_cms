require 'spec_helper'

describe 'Page editing feature', :js => true do
  let(:public_page_1) { FactoryGirl.create(:public_page, :visible => true, :name => 'Page 1') }

  before { authorize_as_admin }

  context "in preview mode" do
    it "the menubar does not render on the page" do
      visit alchemy.edit_admin_page_path(public_page_1)
      within_frame('alchemyPreviewWindow') do
        page.should_not have_selector('#alchemy_menubar')
      end
    end
  end
end
