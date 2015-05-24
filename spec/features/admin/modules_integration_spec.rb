require 'spec_helper'

describe "Modules" do
  context "A custom module with a main-apps controller" do
    before { authorize_user(:as_admin) }

    it "should have a button in main_navigation, pointing to the configured controller" do
      Alchemy::Modules.register_module(
        {
          name: 'events',
          navigation: {
            icon: 'icon events',
            name: 'Events',
            controller: '/admin/events',
            action: 'index'
          }
        })
      visit '/admin'
      click_on 'Events'
      expect(page).not_to have_content('Upps!')
    end

  end
end
