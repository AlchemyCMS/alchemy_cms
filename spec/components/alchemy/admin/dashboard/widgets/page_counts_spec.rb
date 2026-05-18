# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::Dashboard::Widgets::PageCounts, type: :component do
  subject(:rendered) do
    render_inline(described_class.new)
    page
  end

  context "without any pages" do
    it "renders zero count" do
      expect(rendered).to have_css(".widget-body")
      expect(rendered).to have_css(".count", text: "0")
    end

    it "renders zero published pages" do
      expect(rendered).to have_css(".infos", text: "0 #{Alchemy.t("published", scope: "admin.dashboard.widgets.page_counts")}")
    end
  end

  context "with pages" do
    before do
      create(:alchemy_page, :public)
      create(:alchemy_page)
    end

    it "renders the total count of pages" do
      expect(rendered).to have_css(".count", text: Alchemy::Page.count.to_s)
    end

    it "renders the count of published pages" do
      expect(rendered).to have_css(
        ".infos",
        text: "#{Alchemy::Page.published.count} #{Alchemy.t("published", scope: "admin.dashboard.widgets.page_counts")}"
      )
    end
  end

  it "renders the title" do
    expect(rendered).to have_text(Alchemy::Page.model_name.human(count: :many))
  end

  it "renders the icon" do
    expect(rendered).to have_css('alchemy-icon[name="pages"]')
  end

  it "renders a link to the pages admin" do
    expect(rendered).to have_link(href: Alchemy::Engine.routes.url_helpers.admin_pages_path)
  end
end
