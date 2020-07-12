# frozen_string_literal: true

require "rails_helper"
require "timecop"

RSpec.describe "Admin page list", type: :system do
  context "not logged in" do
    specify "it redirects to login" do
      visit admin_pages_path(view: "list")
      expect(page.current_path).to eq(Alchemy.login_path)
    end
  end

  context "as author" do
    let!(:alchemy_page) { create(:alchemy_page, name: "Page 1").tap { |p| p.update!(updated_at: Time.parse("2020-08-20")) } }
    let!(:alchemy_page_2) { create(:alchemy_page, name: "Contact", page_layout: "contact").tap { |p| p.update(updated_at: Time.parse("2020-08-24")) } }
    let!(:alchemy_page_3) { create(:alchemy_page, :layoutpage, name: "Footer") }

    before do
      authorize_user(:as_author)
    end

    specify "displays a table of non layout pages" do
      visit admin_pages_path(view: "list")
      within("table.list") do
        expect(page).to have_css("tr:nth-child(1) td.name:contains('Contact')")
        expect(page).to have_css("tr:nth-child(2) td.name:contains('Intro')")
        expect(page).to have_css("tr:nth-child(3) td.name:contains('Page 1')")
        expect(page).to_not have_css("td.name:contains('Footer')")
      end
    end

    specify "can sort table of pages by name" do
      visit admin_pages_path(view: "list")
      page.find(".sort_link", text: "Name").click
      within("table.list") do
        expect(page).to have_css("tr:nth-child(1) td.name:contains('Page 1')")
        expect(page).to have_css("tr:nth-child(2) td.name:contains('Intro')")
        expect(page).to have_css("tr:nth-child(3) td.name:contains('Contact')")
      end
    end

    specify "can sort table of pages by update date" do
      Timecop.travel("2020-08-25") do
        visit admin_pages_path(view: "list")
        page.find(".sort_link", text: "Updated at").click
        within("table.list") do
          expect(page).to have_css("tr:nth-child(1) td.name:contains('Intro')")
          expect(page).to have_css("tr:nth-child(2) td.name:contains('Contact')")
          expect(page).to have_css("tr:nth-child(3) td.name:contains('Page 1')")
        end
      end
    end

    specify "can filter table of pages by name" do
      visit admin_pages_path(view: "list")
      page.find(".search_input_field").set("Page")
      page.find(".search_field button").click
      within("table.list") do
        expect(page).to have_css("tr:nth-child(1) td.name:contains('Page 1')")
        expect(page).to_not have_css("tr:nth-child(2)")
        expect(page).to_not have_css("tr:nth-child(3)")
      end
    end

    specify "can filter table of pages by status", :js do
      visit admin_pages_path(view: "list")
      select2("Published", from: "Status")
      within("table.list") do
        expect(page.find("tr:nth-child(1) td.name", text: "Intro")).to be
        expect(page).to_not have_css("tr:nth-child(2)")
        expect(page).to_not have_css("tr:nth-child(3)")
      end
    end

    specify "can filter table of pages by type", :js do
      visit admin_pages_path(view: "list")
      select2("Contact", from: "Page type")
      within("table.list") do
        expect(page.find("tr:nth-child(1) td.name", text: "Contact")).to be
        expect(page).to_not have_css("tr:nth-child(2)")
        expect(page).to_not have_css("tr:nth-child(3)")
      end
    end
  end
end
