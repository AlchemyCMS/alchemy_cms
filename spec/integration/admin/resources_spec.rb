require 'spec_helper'
require 'support/integration_spec_helper'

describe "Resources" do

	before(:all) do
		admin_user
		Event.create!(:name => 'My Event',
									:starts_at => DateTime.new(2012, 03, 02, 8, 15),
									:ends_at => DateTime.new(2012, 03, 02, 19, 30),
									:description => "something\nfancy",
									:published => false,
									:entrance_fee => 12.32)
	end

	describe "index view" do

		it "should have a button for creating a new resource items" do
			without_access_control { visit '/admin/events' }
			page.should have_selector('#toolbar div.button_with_label a.icon_button span.icon.create')
		end

		it "should list existing items" do
			without_access_control { visit '/admin/events'
			page.should have_content("My Event")
			page.should have_content("something fancy")
			page.should have_content("12.32") }
		end

		it "should list exising items nicely formatted"

	end

	describe "form for creating and updating items" do
		it "renders an input field according to the attribute's type"
	end

	describe "create resource item" do

		context "when form filled with invalid data" do
			it "lists the new item" do
				without_access_control {
					visit '/admin/events/new'
					fill_in 'event_name', :with => 'My second event'
					fill_in 'event_starts_at', :with => DateTime.new(2012, 03, 03, 20, 00)
					click_on 'Save'
					page.should have_content "My second event"
					page.should have_content "2012-03-03"
				}
			end
		end

		context "when form filled with invalid data" do
			it "shows the form again" do
				without_access_control {
					visit '/admin/events/new'
					fill_in 'event_name', :with => '' #invalid!
					click_on 'Save'
					page.should have_selector "input#event_name"
				}
			end
			it "lists invalid fields"
		end

	end

	describe "updating an item" do
		it "shows the updated value"
	end

	describe "destroying an item" do
		it "should'n be on the list anymore", :js => true do
			pending "Needs js, but doesn't work, neither with selenium nor webkit due to authorative_declaration and a strange sqlite3-error (maybe authlogic...)"

			Event.create!(:name => 'My second Event',
										:starts_at => DateTime.new(2012, 03, 02, 8, 15),
										:ends_at => DateTime.new(2012, 03, 02, 19, 30),
										:description => "something\nfancy",
										:published => false,
										:entrance_fee => 12.32)

			login_into_alchemy
			visit '/admin/events'
			click_link 'Delete'
			page.should have_content "My Event"
			page.should_not have_content "My second Event"
		end
	end

end
