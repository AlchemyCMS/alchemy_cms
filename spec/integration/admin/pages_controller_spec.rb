# Skipping on Travis-CI, because capybara-webkit does not install on travis.
unless ENV["CI"]

	require 'spec_helper'

	describe Alchemy::Admin::PagesController, :js => true do

		describe "language tree switching" do

			context "in a multilangual environment" do

				before(:all) do
					FactoryGirl.build(:admin_user).save_without_session_maintenance
					@language = FactoryGirl.create(:language)
					@german_root = FactoryGirl.create(:language_root_page, :language => Alchemy::Language.get_default, :name => 'Deutsch')
					@klingonian_root = FactoryGirl.create(:language_root_page, :name => 'Klingonian')
				end

				it "one should be able to switch the language tree" do
					login_into_alchemy
					visit('/alchemy/admin/pages')
					page.select 'Klingonian', :from => 'language'
					page.should have_selector('#sitemap .sitemap_pagename_link', :text => 'Klingonian')
				end

				after(:all) {
					@language.destroy
					@klingonian_root.delete
					@german_root.delete
				}

			end

			context "with no language root page" do

				before(:all) do
					FactoryGirl.build(:admin_user).save_without_session_maintenance
					@language = FactoryGirl.create(:language)
				end

				it "it should display the form for creating language root" do
					login_into_alchemy
					visit('/alchemy/admin/pages')
					page.select 'Klingonian', :from => 'language'
					page.should have_content('This language tree does not exist')
				end

				after(:all) {
					@language.destroy
				}

			end

		end

		describe "flush complete page cache" do

			before(:all) do
				FactoryGirl.build(:admin_user).save_without_session_maintenance
			end

			it "should remove the cache of all pages" do
				login_into_alchemy
				visit '/alchemy/admin/pages'
				click_link 'Flush page cache'
				page.should have_content('Page cache flushed')
			end

		end

	end

end
