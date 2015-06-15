# encoding: utf-8
require 'spec_helper'

describe 'Legacy page url management', type: :feature, js: true do
  before do
    authorize_user(:as_admin)
  end

  let!(:a_page) { create(:page) }

  def open_page_properties
    visit admin_pages_path
    within "#page_#{a_page.id}" do
      click_link Alchemy::I18n.t(:edit_page_properties)
    end
  end

  it "lets a user add a page link" do
    open_page_properties
    click_link 'Links'
    fill_in 'legacy_page_url_urlname', with: 'new-urlname'
    click_button 'Add'
    within '#legacy_page_urls' do
      expect(page).to have_content('new-urlname')
    end
    within '#legacy_urls_label' do
      expect(page).to have_content('(1) Link')
    end
  end

  context 'with wrong url format' do
    it "displays error message" do
      open_page_properties
      click_link 'Links'
      fill_in 'legacy_page_url_urlname', with: 'invalid url name'
      click_button 'Add'
      within '#new_legacy_page_url' do
        expect(page).to have_content('URL path is invalid')
      end
    end
  end

  context 'with legacy page url present' do
    before do
      a_page.legacy_urls.create!(urlname: 'a-page-link')
      open_page_properties
      click_link '(1) Link'
    end

    it "lets a user remove a page link" do
      click_link 'Remove'
      click_button 'Yes'
      within '#legacy_page_urls' do
        expect(page).to_not have_content('a-page-link')
        expect(page).to have_content(Alchemy::I18n.t('No page links for this page found'))
      end
      within '#legacy_urls_label' do
        expect(page).to have_content('(0) Links')
      end
    end
  end
end
