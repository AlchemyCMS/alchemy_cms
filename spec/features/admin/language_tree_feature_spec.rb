require 'spec_helper'

describe 'Language tree feature', type: :feature, js: true do
  let(:klingonian) { create(:alchemy_language, :klingonian) }

  before do
    create(:alchemy_page, :language_root)
    authorize_user(:as_admin)
  end

  context "in a multilangual environment" do
    before do
      create(:alchemy_page, :language_root, :name => 'Klingonian', :language => klingonian)
    end

    it "one should be able to switch the language tree" do
      visit('/admin/pages')
      page.select 'Klingonian', from: 'language_id'
      expect(page).to have_selector('#sitemap', text: 'Klingonian')
    end
  end

  context "with no language root page" do
    before { klingonian }

    it "it should display the form for creating language root" do
      visit('/admin/pages')
      page.select 'Klingonian', from: 'language_id'
      expect(page).to have_content('This language tree does not exist')
    end
  end

end
