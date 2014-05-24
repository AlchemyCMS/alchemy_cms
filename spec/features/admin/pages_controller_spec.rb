require 'spec_helper'

module Alchemy
  describe Admin::PagesController, :js => true do

    let(:klingonian) { FactoryGirl.create(:klingonian) }
    let(:german_root) { FactoryGirl.create(:language_root_page) }
    let(:klingonian_root) { FactoryGirl.create(:language_root_page, :name => 'Klingonian', :language => klingonian) }

    before do
      german_root
      authorize_as_admin
    end

    describe "language tree switching" do

      context "in a multilangual environment" do

        before do
          klingonian_root
          Capybara.default_wait_time = 4 # Raising this helps this test to pass, even on travis-ci
        end

        it "one should be able to switch the language tree" do
          visit('/admin/pages')
          page.select 'Klingonian', :from => 'language'
          page.should have_selector('#sitemap', :text => 'Klingonian')
        end

        after { Capybara.default_wait_time = 2 } # Reset to default

      end

      context "with no language root page" do

        before { klingonian }

        it "it should display the form for creating language root" do
          visit('/admin/pages')
          page.select 'Klingonian', :from => 'language'
          page.should have_content('This language tree does not exist')
        end

      end

    end

    describe "flush complete page cache" do

      it "should remove the cache of all pages" do
        visit '/admin/pages'
        click_link 'Flush page cache'
        page.should have_content('Page cache flushed')
      end

    end

  end
end
