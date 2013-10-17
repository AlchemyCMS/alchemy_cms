require 'spec_helper'

describe "Security: " do
  before { Alchemy::Page.root.children.destroy_all }

  context "If no user is present" do
    it "render the signup view" do
      visit '/'
      current_path.should == '/admin/signup'
    end
  end

  context "If user is present" do
    before do
      create_admin_user
    end

    it "a visitor should not be able to signup" do
      visit '/admin/signup'
      within('#alchemy_greeting') { page.should_not have_content('have to signup') }
    end

    context "that is not logged in" do
      it "should see login-form" do
        visit '/admin/dashboard'
        current_path.should == '/admin/login'
      end
    end

    context "that is already logged in" do
      before do
        login_into_alchemy
      end

      it "should be redirected to dashboard" do
        visit '/admin/login'
        current_path.should == '/admin/dashboard'
      end
    end

  end
end
