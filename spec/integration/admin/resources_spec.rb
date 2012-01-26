require 'spec_helper'

describe "Resources" do

	before(:all) do
		Factory.build(:admin_user).save_without_session_maintenance
	end

	describe "index view" do

		it "should have a button for creating a new resource" do
			visit '/alchemy/admin/languages'
			fill_in('Username', :with => 'jdoe')
			fill_in('Password', :with => 's3cr3t')
			click_on('login')
			within('#toolbar') {
				page.should have_selector('div.button_with_label a.icon_button span.icon.create')
			}
		end

	end

end
