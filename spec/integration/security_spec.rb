require 'spec_helper'

describe "Security: " do

  before(:all) do
    Alchemy::Page.root.children.destroy_all
    Alchemy::User.delete_all
  end

  context "If no user is present" do

    it "render the signup view" do
      visit '/alchemy/'
      within('#alchemy_greeting') { page.should have_content('signup') }
    end
  end

  context "If user is present" do

    before(:all) do
      create_admin_user
    end

    it "a visitor should not be able to signup" do
      visit '/alchemy/admin/signup'
      within('#alchemy_greeting') { page.should_not have_content('have to signup') }
    end

    context "that is not logged in" do
      it "should see login-form" do
        visit '/alchemy/admin/dashboard'
        current_path.should == '/alchemy/admin/login'
      end
    end

    context "that is already logged in" do

      before(:each) do
        login_into_alchemy
      end

      it "should be redirected to dashboard" do
        visit '/alchemy/admin/login'
        current_path.should == '/alchemy/admin/dashboard'
      end

    end

  end

end
