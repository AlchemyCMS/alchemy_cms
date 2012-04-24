require 'spec_helper'
require 'support/integration_spec_helper'

describe "Modules" do

  before(:all) do
    FactoryGirl.build(:admin_user).save_without_session_maintenance
  end
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
      login_into_alchemy
      without_access_control do
        visit '/alchemy/admin'
        click_on 'Events'
        page.should_not have_content('Upps!')
      end
    end
  end

end
