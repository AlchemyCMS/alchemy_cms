require 'spec_helper'

describe "Resources" do

	before(:all) do
		FactoryGirl.build(:admin_user).save_without_session_maintenance
	end

	describe "index view" do

		it "should have a button for creating a new resource" do
			login_into_alchemy
			visit '/alchemy/admin/languages'
			page.should have_selector('#toolbar div.button_with_label a.icon_button span.icon.create')
		end

	end

end
