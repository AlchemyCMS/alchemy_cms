# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Show page info feature", type: :system do
  let(:alchemy_page) { create(:alchemy_page) }

  context "as anonymous user" do
    it "redirects to login page" do
      visit alchemy.info_admin_page_path(alchemy_page)
      expect(page).to have_current_path(Alchemy.config.login_path)
    end
  end

  context "as author" do
    before do
      authorize_user(:as_author)
      expect_any_instance_of(Alchemy::Page).to receive(:url_path) { "/en/page-urlname" }
    end

    it "shows page info dialog", :aggregate_failures do
      visit alchemy.info_admin_page_path(alchemy_page)

      within ".resource_info" do
        expect(page).to have_content("Page type Standard")
        expect(page).to have_content("URL-Path /en/page-urlname")
        expect(page).to have_content("Status Page is unavailable for website visitors. Page is accessible by all visitors.")
        expect(page).to have_content("Was created from unknown at " + I18n.l(alchemy_page.created_at, format: :"alchemy.page_status"))
        expect(page).to have_content("Was updated from unknown at " + I18n.l(alchemy_page.updated_at, format: :"alchemy.page_status"))
      end
    end
  end
end
