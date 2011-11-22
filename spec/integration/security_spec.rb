require 'spec_helper'

describe "Security: ", :type => :request do

	before(:each) do
		Alchemy::User.delete_all
		activate_authlogic
	end

	context "If no user is present" do
		it "render the signup view" do
			visit '/alchemy/'
			within('#alchemy_greeting') { page.should have_content('Signup') }
		end
	end

	context "If on or more users are present" do
		it "a visitor should not be able to signup" do
			@user = Alchemy::User.new({:login => 'foo', :email => 'foo@bar.com', :password => 's3cr3t', :password_confirmation => 's3cr3t'})
			@user.save_without_session_maintenance
			visit '/alchemy/admin/signup'
			within('#alchemy_greeting') { page.should_not have_content('have to signup') }
		end
	end

	describe 'User logs in' do

		let(:user) do
			Factory(:admin_user)
		end

		context "if not logged in" do

			it "should show log in form" do
				visit '/alchemy/admin'
				within('#alchemy_greeting') { page.should have_content('identify') }
			end

		end

		context "if already logged in" do

			it "should redirect to dashboard" do
				Alchemy::UserSession.create @user
				visit '/alchemy/admin/login'
				current_path.should == '/alchemy/admin/dashboard'
			end

		end

	end

end
