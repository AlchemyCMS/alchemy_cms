# frozen_string_literal: true

require "rails_helper"

class TestTab < Alchemy::Admin::LinkDialog::BaseTab
  def title
    "Test Tab"
  end

  def self.panel_name
    :test_tab
  end

  def fields
    [title_input, target_select]
  end
end

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

    context "add new tab" do
      before do
        stub_alchemy_config(link_dialog_tabs: [TestTab])
      end

      it "has a new tab" do
        visit link_admin_pages_path
        within("#overlay_tabs") { expect(page).to have_content("Test Tab") }
      end
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
        autogenerate_ingredients: true
      )
    end

    it "should be possible to link a page" do
      visit edit_admin_page_path(page1)

      within "#element_#{article.id} .ingredient-editor.text.linkable" do
        fill_in "Intro", with: "Link me"
        click_button_with_tooltip Alchemy.t(:place_link)
      end

      within "[name='overlay_tab_internal_link']" do
        expect(page).to have_selector(".ts-control")
        tom_select_search(page2.name, from: "Page")
        click_button "apply"
      end

      within "#element_#{article.id} .element-footer" do
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

      within "#element_#{article.id} .ingredient-editor.text.linkable" do
        fill_in "Intro", with: "Link me"
        click_button_with_tooltip Alchemy.t(:place_link)
      end

      within "#overlay_tabs" do
        find("[panel='overlay_tab_external_link']").click
      end

      within "[name='overlay_tab_external_link']" do
        expect(page).to have_selector("#external_link")
        fill_in("URL", with: "https://example.com")
        click_button "apply"
      end

      within "#element_#{article.id} .element-footer" do
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

      within "#element_#{article.id} .ingredient-editor.text.linkable" do
        fill_in "Intro", with: "Link me"
        click_button_with_tooltip Alchemy.t(:place_link)
      end

      within "#overlay_tabs" do
        find("[panel='overlay_tab_file_link']").click
      end

      within "[name='overlay_tab_file_link']" do
        expect(page).to have_selector(".ts-control")
        tom_select_search(file.name, from: "File")
        click_button "apply"
      end

      within "#element_#{article.id} .element-footer" do
        click_button "Save"
      end

      within "#flash_notices" do
        expect(page).to have_content "Saved element."
      end

      expect(page).to have_css("iframe#alchemy_preview_window", wait: 5)
      within_frame "alchemy_preview_window" do
        expect(page).to have_link("Link me", href: "/attachment/#{file.id}/download/#{file.file_name}")
      end
    end

    it "keeps the selected page and its anchor separate when editing a link" do
      visit link_admin_pages_path(url: "#{page2.url_path}#some-anchor", selected_tab: "internal")

      within "[name='overlay_tab_internal_link']" do
        # The page select shows the page, not the raw url with the anchor.
        expect(page).to have_selector("alchemy-page-select .ts-control .item", text: page2.name)
        # The url (page path + anchor) is kept so the link can be applied.
        expect(find("#internal_link", visible: :all).value).to eq("#{page2.url_path}#some-anchor")
        find("alchemy-page-select .ts-control").click
      end

      # Opening the page select must not offer the raw url as a bogus option.
      expect(page).to have_selector(".ts-dropdown .option")
      expect(page).to_not have_selector(".ts-dropdown .option", text: "some-anchor")
    end

    it "clears stale results and shows a no-results notice for a non-matching search" do
      visit link_admin_pages_path(selected_tab: "internal")

      within "[name='overlay_tab_internal_link']" do
        find("alchemy-page-select .ts-control").click
      end

      # The initial list is preloaded on focus (the dropdown is appended to body).
      expect(page).to have_selector(".ts-dropdown .option", text: page1.name)

      within "[name='overlay_tab_internal_link'] alchemy-page-select .ts-control" do
        find("input").send_keys("Nonexistentpagexyz")
      end

      # The previously loaded options must be cleared once the search has no match.
      expect(page).to_not have_selector(".ts-dropdown .option", text: page1.name)
      # And a no-results notice is shown instead.
      expect(page).to have_selector(".ts-dropdown .no-results")
    end

    it "clears the selected page from the results when the search has no match" do
      visit link_admin_pages_path(url: page2.url_path, selected_tab: "internal")

      within "[name='overlay_tab_internal_link']" do
        expect(page).to have_selector("alchemy-page-select .ts-control .item", text: page2.name)
        find("alchemy-page-select .ts-control").click
      end

      expect(page).to have_selector(".ts-dropdown .option", text: page2.name)

      within "[name='overlay_tab_internal_link'] alchemy-page-select .ts-control" do
        find("input").send_keys("Nonexistentpagexyz")
      end

      # The selected page is an option as well and must not survive the search.
      expect(page).to_not have_selector(".ts-dropdown .option")
      expect(page).to have_selector(".ts-dropdown .no-results")
      # It stays selected though.
      within "[name='overlay_tab_internal_link']" do
        expect(page).to have_selector("alchemy-page-select .ts-control .item", text: page2.name)
      end
    end

    it "shows a spinner in the control while the pages load" do
      visit link_admin_pages_path(selected_tab: "internal")

      within "[name='overlay_tab_internal_link']" do
        find("alchemy-page-select .ts-control").click
        # The spinner is hidden by default and revealed while results load.
        expect(page).to have_selector(".ts-control sl-spinner", visible: true)
      end

      expect(page).to have_selector(".ts-dropdown .option")
    end
  end
end
