# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Confirm dialog", type: :system, js: true do
  before { authorize_user(:as_admin) }

  let!(:a_page) { create(:alchemy_page) }

  context "opened while a modal dialog is open" do
    # A modal <dialog> renders in the top layer and makes the rest of the page
    # inert, so a confirm appended to the body would be hidden below it and
    # unclickable. It has to be appended into the open dialog instead.
    it "renders above the dialog and stays interactable" do
      visit alchemy.admin_pages_path
      within ".sitemap_page[name='#{a_page.name}']" do
        click_icon("settings-3")
      end
      expect(page).to have_css(".alchemy-dialog-container.open")

      page.execute_script(<<~JS)
        window.__confirmed = null
        Turbo.config.forms.confirm("Really?").then((result) => {
          window.__confirmed = result
        })
      JS

      within "sl-dialog" do
        find("button[type=submit]").click
      end

      expect(page).to have_no_css("sl-dialog")
      expect(page.evaluate_script("window.__confirmed")).to be(true)
    end
  end
end
