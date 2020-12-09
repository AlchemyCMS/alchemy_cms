# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Link overlay", type: :system do
  let!(:language) { create(:alchemy_language) }

  before do
    authorize_user(:as_admin)
  end

  context "GUI" do
    it "has a tab for linking internal pages" do
      visit link_admin_pages_path
      within("#overlay_tabs") { expect(page).to have_content("Internal") }
    end

    it "has a tab for adding anchor links" do
      visit link_admin_pages_path
      within("#overlay_tabs") { expect(page).to have_content("Anchor") }
    end

    it "has a tab for linking external pages" do
      visit link_admin_pages_path
      within("#overlay_tabs") { expect(page).to have_content("External") }
    end

    it "has a tab for linking files" do
      visit link_admin_pages_path
      within("#overlay_tabs") { expect(page).to have_content("File") }
    end
  end

  context "linking pages", js: true do
    let(:lang_root) do
      create(:alchemy_page, :language_root)
    end

    let!(:page1) do
      create(:alchemy_page, :public, parent_id: lang_root.id)
    end

    let!(:page2) do
      create(:alchemy_page, :public, parent_id: lang_root.id)
    end

    let!(:article) do
      create(:alchemy_element,
        name: "article",
        page: page1,
        page_version: page1.draft_version,
        autogenerate_contents: true)
    end

    it "should be possible to link a page" do
      visit edit_admin_page_path(page1)

      within "#element_#{article.id}" do
        fill_in "Headline", with: "Link me"
        click_link "Link text"
      end

      begin
        within "#overlay_tab_internal_link" do
          expect(page).to have_selector("#s2id_page_urlname")
          select2_search(page2.name, from: "Page")
          click_link "apply"
        end

        within "#element_#{article.id}" do
          click_button "Save"
        end

        within "#flash_notices" do
          expect(page).to have_content "Saved element."
        end

        click_button_with_label "Publish page"

        visit "/#{page1.urlname}"

        expect(page).to have_link("Link me", href: "/#{page2.urlname}")
      rescue Capybara::ElementNotFound => e
        pending e.message
        raise e
      end
    end
  end
end
