require 'spec_helper'

describe "Security: " do
  include Capybara::DSL
  
  before(:each) do
    Alchemy::User.delete_all
  end
  
  context "If no user is present" do
    it "render the signup view" do
      visit '/'
      within('#alchemy_greeting') { page.should have_content('Signup') }
    end
  end
  
  context "If on or more users are present" do
    it "a visitor should not be able to signup" do
      @user = Alchemy::User.new({:login => 'foo', :email => 'foo@bar.com', :password => 's3cr3t', :password_confirmation => 's3cr3t'})
      @user.save_without_session_maintenance
      visit '/admin/signup'
      within('#alchemy_greeting') { page.should_not have_content('have to signup') }
    end
  end
  
end
