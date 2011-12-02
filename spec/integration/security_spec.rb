require 'spec_helper'

describe "Security: " do

	context "If no user is present" do
		
		before(:all) do
			Alchemy::User.delete_all
			# ensuring that we have the correct locale here
			::I18n.locale = :en
		end
		
		it "render the signup view" do
			visit '/alchemy/'
			within('#alchemy_greeting') { page.should have_content('signup') }
		end
	end
	
	context "If user is present" do

		before(:all) do
			Factory.build(:admin_user).save_without_session_maintenance
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
			before(:all) do
				visit '/alchemy/admin/login'
				fill_in('alchemy_user_session_login', :with => 'jdoe')
				fill_in('alchemy_user_session_password', :with => 's3cr3t')
				click_on('Login')
			end
			
			it "should be redirected to dashboard" do
				visit '/alchemy/admin/login'
				current_path.should == '/alchemy/admin/dashboard'
			end
		end
		
	end

end
