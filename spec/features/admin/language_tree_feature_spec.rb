# frozen_string_literal: true

require 'spec_helper'

describe 'Language tree feature', type: :feature, js: true do
  let(:klingon) { create(:alchemy_language, :klingon) }

  before do
    create(:alchemy_page, :language_root)
    authorize_user(:as_admin)
  end

  context "in a multilangual environment" do
    before do
      create(:alchemy_page, :language_root, name: 'Klingon', language: klingon)
    end

    it "one should be able to switch the language tree" do
      visit('/admin/pages')
      select2 'Klingon', from: 'Language tree'
      expect(page).to have_selector('#sitemap', text: 'Klingon')
    end
  end

  context "with no language root page" do
    before { klingon }

    it "displays a form for creating language root with preselected page layout and front page name" do
      visit('/admin/pages')
      select2 'Klingon', from: 'Language tree'
      expect(page).to have_content('This language tree does not exist')

      within('form#create_language_tree') do
        expect(page).to \
          have_selector('input[type="text"][value="' + klingon.frontpage_name + '"]')
        expect(page).to have_selector('option[selected="selected"][value="' + klingon.page_layout + '"]')
      end
    end
  end
end
