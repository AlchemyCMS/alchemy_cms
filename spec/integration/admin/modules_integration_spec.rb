require 'spec_helper'

describe "Modules" do

  context "A custom module with a main-apps controller" do

    before(:each) do
      load_authorization_rules
      create_admin_user
      login_into_alchemy
    end

    it "should have a button in main_navigation, pointing to the configured controller" do
      Alchemy::Modules.register_module(
        {
          :name => 'events',
          :navigation => {
            :icon => 'icon events',
            :name => 'Events',
            :controller => '/admin/events',
            :action => 'index'
          }
        })
      visit '/alchemy/admin'
      click_on 'Events'
      page.should_not have_content('Upps!')
    end

  end

end
