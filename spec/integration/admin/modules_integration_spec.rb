require 'spec_helper'
require 'support/integration_spec_helper'

describe "Modules" do

  describe "a custom module with a main-apps controller" do
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
      create_admin_user
      login_with_admin_user
      visit '/alchemy/admin'
      click_on 'Events'
      page.should_not have_content('Upps!')
    end
  end

end
