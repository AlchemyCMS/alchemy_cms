# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Alchemy::Admin::PageDefinitionsController" do
  before do
    authorize_user(:as_author)
  end

  describe "GET /admin/page_definitions" do
    it "lists all page definitions" do
      get alchemy.admin_page_definitions_path
      expect(response.body).to include('id="standard"', 'id="everything"')
    end

    it "links content page definitions to the filtered page list" do
      create(:alchemy_page, page_layout: "news")

      get alchemy.admin_page_definitions_path
      expect(Capybara.string(response.body)).to have_link("Show 1 Page",
        href: alchemy.admin_pages_path(view: "list", q: {by_page_layout: "news"}))
    end

    it "links global page definitions to the global pages" do
      create(:alchemy_page, :layoutpage, page_layout: "footer")

      get alchemy.admin_page_definitions_path
      expect(Capybara.string(response.body)).to have_link("Show 1 Page", href: alchemy.admin_layoutpages_path)
    end

    it "shows how often page definitions and elements are used" do
      page = create(:alchemy_page, page_layout: "news")
      create_list(:alchemy_element, 3, name: "headline", page_version: page.draft_version)
      contact_page = create(:alchemy_page, page_layout: "contact")
      create_list(:alchemy_element, 2, name: "headline", page_version: contact_page.draft_version)
      published_version = create(:alchemy_page_version, :published, page: page)
      create(:alchemy_element, name: "headline", page_version: published_version)

      get alchemy.admin_page_definitions_path
      html = Capybara.string(response.body)
      expect(html).to have_css("h2#news small", text: "Show 1 Page")
      expect(html).to have_css("h2#news ~ .elements summary", text: %r{Headline\s+3 / 5})
      expect(html).to have_css("h2#contact ~ .elements summary", text: %r{Headline\s+2 / 5})
      expect(html).to have_css('h2#news ~ .elements summary sl-tooltip[content="On this page type: 3 · In total: 5"]')
    end

    it "counts page and element usages with one query each" do
      count_queries = []
      callback = ->(*, payload) { count_queries << payload[:sql] if payload[:sql].include?("COUNT") }
      ActiveSupport::Notifications.subscribed(callback, "sql.active_record") do
        get alchemy.admin_page_definitions_path
      end
      expect(count_queries.size).to eq(2)
    end

    context "with query" do
      it "only lists page definitions with matching nested elements" do
        get alchemy.admin_page_definitions_path(q: "Gallery picture")
        expect(response.body).to include('id="everything"')
        expect(response.body).not_to include('id="standard"')
      end

      it "unfolds elements with matching nested elements" do
        get alchemy.admin_page_definitions_path(q: "Gallery picture")
        page = Capybara.string(response.body)
        expect(page).to have_css("details[open] > summary", text: "Gallery", count: 1)
        expect(page).to have_css("details[open]", count: 1)
      end

      it "highlights matches in page definition and element names" do
        get alchemy.admin_page_definitions_path(q: "every")
        page = Capybara.string(response.body)
        expect(page).to have_css("aside a mark", text: "Every")
        expect(page).to have_css("h2#everything mark", text: "Every")

        get alchemy.admin_page_definitions_path(q: "picture")
        page = Capybara.string(response.body)
        expect(page).to have_css("details summary mark", text: "picture")
      end

      it "shows a message if nothing matches" do
        get alchemy.admin_page_definitions_path(q: "nothing matches this")
        expect(response.body).to include("Nothing found")
      end
    end
  end
end
