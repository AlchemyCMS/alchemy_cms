# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Language tree feature', type: :system, js: true do
  let(:klingon) { create(:alchemy_language, :klingon) }
  let(:user) { build(:alchemy_dummy_user, :as_admin) }

  before do
    create(:alchemy_page, :language_root)
    authorize_user(user)
  end

  context "with a single language" do
    it "one should not be able to switch the language tree" do
      visit('/admin/pages')
      expect(page).to_not have_selector('label', text: Alchemy.t("Language tree"))
    end
  end

  context "in a multilangual environment" do
    context 'even if one language is not public' do
      let(:klingon) { create(:alchemy_language, :klingon, public: false) }

      before do
        create(:alchemy_page, :language_root, name: 'Klingon', language: klingon)
      end

      context 'and an author' do
        let(:user) { build(:alchemy_dummy_user, :as_author) }

        it "one should not be able to switch the language tree" do
          visit('/admin/pages')
          expect(page).to_not have_selector('label', text: Alchemy.t("Language tree"))
        end
      end

      context 'and an editor' do
        let(:user) { build(:alchemy_dummy_user, :as_editor) }

        it "one should be able to switch the language tree" do
          visit('/admin/pages')
          expect(page).to have_selector('label', text: Alchemy.t("Language tree"))
        end
      end
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
