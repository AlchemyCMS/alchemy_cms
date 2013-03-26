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
          page.should have_css("input[type='checkbox']")

          fill_in "Stylesheet", with: "disco"
          check "Is awesome"

          click_on "Save"
        end

        visit "/admin/sites"

        click_on "Edit the site's properties"

        within "#alchemyOverlay" do
          page.should have_field("Stylesheet", with: "disco")
          page.should have_checked_field("Is awesome")
        end
      end
    end

  end
end
