require 'spec_helper'

module Alchemy
  describe Admin::SitesController, :js => true do

    context "site properties" do
      let!(:german_root) { FactoryGirl.create(:language_root_page) }
      before do
        authorize_as_admin
      end

      it "sets value and then retrieves value" do
        visit "/admin/sites"
        click_on "Edit the site's properties"

        within "#alchemyOverlay" do
          page.should have_css("input[type='text']")

          fill_in "Stylesheet", with: "disco"

          click_on "Save"
        end

        visit "/admin/sites"

        click_on "Edit the site's properties"

        within "#alchemyOverlay" do
          page.should have_field("Stylesheet", with: "disco")
        end
      end
    end
  end
end
