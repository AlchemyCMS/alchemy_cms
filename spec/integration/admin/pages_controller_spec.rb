# Skipping on Travis-CI, because capybara-webkit does not install on travis.
unless ENV["CI"]

require 'spec_helper'

describe Alchemy::Admin::PagesController, :js => true do

	describe "language tree switching" do

		context "in a multilangual environment" do

			before(:all) do
				Factory.build(:admin_user).save_without_session_maintenance
				@language = Factory(:language)
				@german_root = Factory(:language_root_page, :language => Alchemy::Language.get_default, :name => 'Deutsch')
				@klingonian_root = Factory(:language_root_page, :name => 'Klingonian')
			end

			it "one should be able to switch the language tree" do
				login_to_alchemy
				visit('/alchemy/admin/pages')
				page.select 'Klingonian', :from => 'language'
				within('#sitemap') { page.should have_content('Klingonian') }
			end

			after(:all) {
				@language.destroy
				@klingonian_root.destroy
				@german_root.destroy
			}

		end

		context "with no language root page" do

			before(:all) do
				Factory.build(:admin_user).save_without_session_maintenance
				@language = Factory(:language)
			end

			it "it should display the form for creating language root" do
				login_to_alchemy
				visit('/alchemy/admin/pages')
				page.select 'Klingonian', :from => 'language'
				within('#archive_all') do
					page.should have_content('This language tree does not exist')
				end
			end

			after(:all) {
				@language.destroy
			}

		end

	end

	describe "flush complete page cache" do

		before(:all) do
			Factory.build(:admin_user).save_without_session_maintenance
		end

		it "should remove the cache of all pages" do
			login_to_alchemy
			visit '/alchemy/admin/pages'
			click_link 'Flush page cache'
			within('#flash_notices') do
				page.should have_content('Page cache flushed')
			end
		end

	end

end

# We need this, because the before blocks losing its session under webkit-capybara (https://github.com/thoughtbot/capybara-webkit/issues/222)
def login_to_alchemy
	visit '/alchemy/admin/login'
	fill_in('Username', :with => 'jdoe')
	fill_in('Password', :with => 's3cr3t')
	click_on('login')
end

end
