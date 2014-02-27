require 'spec_helper'

describe 'Language tree feature', js: true do

  let(:klingonian) { FactoryGirl.create(:klingonian) }
  let(:german_root) { FactoryGirl.create(:language_root_page) }
  let(:klingonian_root) { FactoryGirl.create(:language_root_page, :name => 'Klingonian', :language => klingonian) }

  before do
    german_root
    authorize_as_admin
  end

  context "in a multilangual environment" do
    before { klingonian_root }

    it "one should be able to switch the language tree" do
      visit('/admin/pages')
      page.select 'Klingonian', from: 'language_id'
      page.should have_selector('#sitemap', text: 'Klingonian')
    end
  end

  context "with no language root page" do
    before { klingonian }

    it "it should display the form for creating language root" do
      visit('/admin/pages')
      page.select 'Klingonian', from: 'language_id'
      page.should have_content('This language tree does not exist')
    end
  end

end
