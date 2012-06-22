require 'spec_helper'

module Alchemy
  describe Admin::PagesController, :js => true do

    before(:all) do
      create_admin_user
      @german_root = FactoryGirl.create(:language_root_page, :language => Language.get_default, :name => 'Deutsch')
    end

    before(:each) do
      login_into_alchemy
    end

    describe "language tree switching" do

      before(:all) do
        @language = FactoryGirl.create(:language)
      end

      context "in a multilangual environment" do

        before(:all) do
          @klingonian_root = FactoryGirl.create(:language_root_page, :name => 'Klingonian')
        end

        it "one should be able to switch the language tree" do
          visit('/alchemy/admin/pages')
          page.select 'Klingonian', :from => 'language'
          page.should have_selector('#sitemap .sitemap_pagename_link', :text => 'Klingonian')
        end

        after(:all) {
          @klingonian_root.delete
        }

      end

      context "with no language root page" do

        it "it should display the form for creating language root" do
          visit('/alchemy/admin/pages')
          page.select 'Klingonian', :from => 'language'
          page.should have_content('This language tree does not exist')
        end

      end

      after(:all) {
        @language.destroy
      }

    end

    describe "flush complete page cache" do

      it "should remove the cache of all pages" do
        visit '/alchemy/admin/pages'
        click_link 'Flush page cache'
        page.should have_content('Page cache flushed')
      end

    end

    after(:all) {
      @german_root.delete
    }

  end
end
