# frozen_string_literal: true

require 'spec_helper'

describe 'Locked pages feature' do
  let(:a_page) { create(:alchemy_page) }

  let(:user) do
    create(:alchemy_dummy_user, :as_author)
  end

  before do
    a_page.lock_to!(user)
    authorize_user(user)
  end

  it 'displays tab for each locked page' do
    visit alchemy.admin_pages_path

    within '#locked_pages' do
      expect(page).to have_link a_page.name, href: alchemy.edit_admin_page_path(a_page)
    end
  end

  context 'with multiple languages' do
    let!(:language) do
      create(:alchemy_language, :klingon)
    end

    it 'displays information for language' do
      visit alchemy.admin_pages_path

      within "#locked_page_#{a_page.id}" do
        expect(page).to have_content a_page.language.code
      end
    end
  end

  context 'with multiple sites' do
    let!(:site) do
      create(:alchemy_site, host: 'another-site.com')
    end

    it 'displays information for site' do
      visit alchemy.admin_pages_path

      within "#locked_page_#{a_page.id}" do
        expect(page).to have_content a_page.site.name
      end
    end
  end
end
