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
      create(
        :alchemy_element,
        name: "article",
        page_version: page1.draft_version,
        autogenerate_ingredients: true,
      )
    end

    it "should only return pages from the language of the page being edited" do
      page_in_other_language = create :alchemy_page, :public, language: create(:alchemy_language, language_code: "es", public: true)

      visit edit_admin_page_path(page1)

      within "#element_#{article.id}" do
        fill_in "Intro", with: "Link me"
        click_link "Link text"
      end

      within "#overlay_tab_internal_link" do
        expect(page).to have_selector("#s2id_internal_link")
        expect { select2(page_in_other_language.name, from: "Page") }.to raise_error(Capybara::ElementNotFound)
        expect(find("#internal_link").value).not_to eq page_in_other_language.urlname
      end
    end

    it "should be possible to link a page" do
      visit edit_admin_page_path(page1)

      within "#element_#{article.id}" do
        fill_in "Intro", with: "Link me"
        click_link "Link text"
      end

      within "#overlay_tab_internal_link" do
        expect(page).to have_selector("#s2id_internal_link")
        select2_search(page2.name, from: "Page")
        click_button "apply"
      end

      within "#element_#{article.id}" do
        click_button "Save"
      end

      within "#flash_notices" do
        expect(page).to have_content "Saved element."
      end

      expect(page).to have_css("iframe#alchemy_preview_window", wait: 5)
      within_frame "alchemy_preview_window" do
        expect(page).to have_link("Link me", href: "/#{page2.urlname}")
      end
    end

    it "should be possible to link an external url" do
      visit edit_admin_page_path(page1)

      within "#element_#{article.id}" do
        fill_in "Intro", with: "Link me"
        click_link "Link text"
      end

      within "#overlay_tabs" do
        click_link "External"
      end

      within "#overlay_tab_external_link" do
        expect(page).to have_selector("#external_link")
        fill_in("URL", with: "https://example.com")
        click_button "apply"
      end

      within "#element_#{article.id}" do
        click_button "Save"
      end

      within "#flash_notices" do
        expect(page).to have_content "Saved element."
      end

      expect(page).to have_css("iframe#alchemy_preview_window", wait: 5)
      within_frame "alchemy_preview_window" do
        expect(page).to have_link("Link me", href: "https://example.com")
      end
    end

    it "should be possible to link a file" do
      file = create(:alchemy_attachment)
      visit edit_admin_page_path(page1)

      within "#element_#{article.id}" do
        fill_in "Intro", with: "Link me"
        click_link "Link text"
      end

      within "#overlay_tabs" do
        click_link "File"
      end

      within "#overlay_tab_file_link" do
        expect(page).to have_selector("#file_link")
        select2(file.name, from: "File")
        click_button "apply"
      end

      within "#element_#{article.id}" do
        click_button "Save"
      end

      within "#flash_notices" do
        expect(page).to have_content "Saved element."
      end

      expect(page).to have_css("iframe#alchemy_preview_window", wait: 5)
      within_frame "alchemy_preview_window" do
        expect(page).to have_link("Link me", href: "/attachment/#{file.id}/download/#{file.name}")
      end
    end
  end
end
