require 'spec_helper'

describe 'Language tree feature', type: :feature, js: true do
  let(:klingon) { create(:alchemy_language, :klingon) }

  before do
    create(:alchemy_page, :public, :language_root)
    authorize_user(:as_admin)
  end

  context "in a multilangual environment" do
    before do
      create(:alchemy_page, :public, :language_root, name: 'Klingon', language: klingon)
    end

    it "one should be able to switch the language tree" do
      visit('/admin/pages')
      page.select 'Klingon', from: 'language_id'
      expect(page).to have_selector('#sitemap', text: 'Klingon')
    end
  end

  context "with no language root page" do
    before { klingon }

    it "it should display the form for creating language root" do
      visit('/admin/pages')
      page.select 'Klingon', from: 'language_id'
      expect(page).to have_content('This language tree does not exist')
    end
  end
end
