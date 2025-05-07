# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Legacy page url management", type: :system, js: true do
  before do
    authorize_user(:as_admin)
  end

  let!(:a_page) { create(:alchemy_page) }

  def open_page_properties
    visit admin_pages_path
    expect(page.find("alchemy-overlay")).to_not have_css(".visible")
    page.find("a[href='#{configure_admin_page_path(a_page)}']", wait: 10).click
  end

  it "lets a user add a page link" do
    open_page_properties
    find("[panel='legacy_urls']").click
    fill_in "legacy_page_url_urlname", with: "new-urlname"
    click_button "Add"
    within "#legacy_page_urls" do
      expect(page).to have_content("new-urlname")
    end
    within "#legacy_urls_label" do
      expect(page).to have_content("(1) Link")
    end
  end

  context "with wrong url format" do
    it "displays error message" do
      open_page_properties
      find("[panel='legacy_urls']").click
      fill_in "legacy_page_url_urlname", with: "invalid url name"
      click_button "Add"
      within "#new_legacy_page_url" do
        expect(page).to have_content("URL-Path is invalid")
      end
    end
  end

  context "with legacy page url present" do
    before do
      a_page.legacy_urls.create!(urlname: "a-page-link")
      open_page_properties
      find("[panel='legacy_urls']").click
    end

    it "lets a user update a page link" do
      within "#legacy_page_urls" do
        click_link_with_tooltip("Edit")
        page.find("input#legacy_page_url_urlname").set("updated-link")
        click_button_with_tooltip "Save"
      end
      within "sl-tab-panel[name='legacy_urls']" do
        expect(page).to have_button("Add")
      end
      within "#legacy_page_urls" do
        expect(page).to_not have_content("a-page-link")
        expect(page).to have_content("updated-link")
      end
    end

    it "lets a user remove a page link" do
      click_link_with_tooltip("Remove")

      within "sl-dialog[open]" do
        click_button "Yes"
      end

      within "#legacy_page_urls" do
        expect(page).to_not have_content("a-page-link")
        expect(page).to have_content(Alchemy.t("No page links for this page found"))
      end
      within "#legacy_urls_label" do
        expect(page).to have_content("(0) Links")
      end
    end
  end
end
