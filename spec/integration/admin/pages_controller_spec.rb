require 'spec_helper'

describe Alchemy::Admin::PagesController do

	describe "language tree switching", :js => true do

		context "in a multilangual environment" do

			before(:each) do
				Factory.build(:admin_user).save_without_session_maintenance
				Factory(:language)
				Factory(:language_root_page, :language => Alchemy::Language.get_default, :name => 'Deutsch')
				Factory(:language_root_page, :name => 'Klingonian')
			end

			it "one should be able to switch the language tree" do
				pending "This driver does not execute javascript as it should"
				login_to_alchemy
				visit('/alchemy/admin/pages')
				page.select 'Klingonian', :from => 'language'
				within('#sitemap') { page.should have_content('Klingonian') }
			end

		end

		context "with no language root page" do

			before(:each) do
				Factory.build(:admin_user).save_without_session_maintenance
			end

			it "it should display the form for creating or copy language root" do
				pending "This driver does not work."
				login_to_alchemy
				visit('/alchemy/admin/pages')
				save_and_open_page
				within('#archive_all') do
					page.should have_content('This language tree does not exist')
					page.should have_content('Do you want to copy')
					page.should have_content('do you want to create a new empty language tree')
				end
			end

		end

	end

end

# We need this, because the before blocks losing its session under webkit-capybara (https://github.com/thoughtbot/capybara-webkit/issues/222)
def login_to_alchemy
	visit '/alchemy/admin/login'
	fill_in('alchemy_user_session_login', :with => 'jdoe')
	fill_in('alchemy_user_session_password', :with => 's3cr3t')
	click_on('Login')
end
