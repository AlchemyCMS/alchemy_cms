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

    it "lists global page definitions after content page definitions" do
      get alchemy.admin_page_definitions_path
      html = Capybara.string(response.body)
      expect(html.all(".page-definition h2").map { _1[:id] }.last).to eq("footer")
      expect(html.find("aside h2").text.squish).to eq("10 Page Types")
      expect(html.all("aside h3").map { _1.text.squish }).to eq(["Content Pages 9", "Global Pages 1"])
      expect(html).to have_css("aside h3:last-of-type + ol li", text: "Footer", count: 1)
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

    context "with page type filter" do
      it "only lists the filtered page definition" do
        get alchemy.admin_page_definitions_path(q: {name_eq: "everything"})
        html = Capybara.string(response.body)
        expect(html.all(".page-definition h2").map { _1[:id] }).to eq(["everything"])
      end

      it "still lists and highlights all page types in the sidebar" do
        get alchemy.admin_page_definitions_path(q: {name_eq: "everything"})
        html = Capybara.string(response.body)
        expect(html).to have_css("aside li", text: "Standard")
        expect(html).to have_css("aside li.active", text: "Everything", count: 1)
        expect(html).to have_css("aside li.active sl-tooltip[content='Show all page types'] a.icon_button.active")
        expect(html).to have_link("Everything", href: "#everything")
        expect(html).to have_link("Standard", href: alchemy.admin_page_definitions_path(anchor: "standard"))
      end

      it "shows a button to remove the filter in the panel heading" do
        get alchemy.admin_page_definitions_path(q: {name_eq: "everything", name_or_elements_cont: "picture"})
        html = Capybara.string(response.body)
        expect(html).to have_css("aside h2 sl-tooltip[content='Show all page types'] a.icon_button.active[href='#{alchemy.admin_page_definitions_path(q: {name_or_elements_cont: "picture"})}']")

        get alchemy.admin_page_definitions_path
        expect(Capybara.string(response.body)).not_to have_css("aside h2 .icon_button")
      end

      it "shows a message for an unknown page type" do
        get alchemy.admin_page_definitions_path(q: {name_eq: "unknown"})
        expect(response.body).to include("Nothing found")
      end
    end

    context "with search query" do
      it "does not hide page definitions" do
        get alchemy.admin_page_definitions_path(q: {name_or_elements_cont: "Gallery picture"})
        expect(response.body).to include('id="everything"', 'id="standard"')
      end

      it "unfolds elements with matching nested elements" do
        get alchemy.admin_page_definitions_path(q: {name_or_elements_cont: "Gallery picture"})
        page = Capybara.string(response.body)
        expect(page).to have_css("details[open] > summary", text: "Gallery", count: 1)
        expect(page).to have_css("details[open]", count: 1)
      end

      it "highlights matches in page definition and element names" do
        get alchemy.admin_page_definitions_path(q: {name_or_elements_cont: "every"})
        page = Capybara.string(response.body)
        expect(page).to have_css("aside a mark", text: "Every")
        expect(page).to have_css("h2#everything mark", text: "Every")

        get alchemy.admin_page_definitions_path(q: {name_or_elements_cont: "picture"})
        page = Capybara.string(response.body)
        expect(page).to have_css("details summary mark", text: "picture")
      end

      it "highlights within the filtered page type and keeps the filter when searching" do
        get alchemy.admin_page_definitions_path(q: {name_eq: "everything", name_or_elements_cont: "picture"})
        page = Capybara.string(response.body)
        expect(page.all(".page-definition h2").map { _1[:id] }).to eq(["everything"])
        expect(page).to have_css("details summary mark", text: "picture")
        expect(page).to have_field("q[name_eq]", type: :hidden, with: "everything")
      end
    end
  end
end
