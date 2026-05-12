# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::Dashboard::Widgets::PageUsage, type: :component do
  subject(:render) { render_inline(described_class.new) }

  let(:definition_count) { Alchemy::PageDefinition.all.size }

  context "without any pages" do
    before { render }

    it "renders a row for each defined page layout" do
      expect(page).to have_selector("table.usage-stats tr", count: definition_count)
    end

    it "renders a total of zero" do
      expect(page).to have_selector("aside", text: "0")
    end

    it "renders 0.00% for each row" do
      percentages = page.all("td.usage-stats--value:first-of-type").map(&:text).map(&:strip)
      expect(percentages.uniq).to eq(["0.00%"])
    end
  end

  context "with both published and draft pages" do
    before do
      # creates a :public language_root with page_layout: "index"
      create(:alchemy_page, :public, page_layout: "standard")
      create(:alchemy_page, page_layout: "standard")
      create(:alchemy_page, page_layout: "news")
      render
    end

    it "shows the combined public + draft count in the header total" do
      expect(page).to have_selector("aside", text: "4") # 1 index + 2 standard + 1 news
    end

    it "renders a stacked bar with both segments for layouts that have both" do
      standard_bar = page.find("td.usage-stats--label", text: "Standard").ancestor("tr").find("span.bar")
      expect(standard_bar.find("span.bar__public", visible: :all)["style"]).to include("width: 50.0%")
      expect(standard_bar.find("span.bar__draft", visible: :all)["style"]).to include("width: 50.0%")
    end

    it "mentions both counts in the combined sl-tooltip" do
      standard_row = page.find("td.usage-stats--label", text: "Standard").ancestor("tr")
      tooltip = standard_row.find("td.usage-stats--bar sl-tooltip", visible: :all)
      expect(tooltip["content"]).to include("1 Published").and include("1 Draft")
    end

    it "sorts layouts by combined public + draft count descending" do
      labels = page.all("td.usage-stats--label").map(&:text).map(&:strip)
      expect(labels.first).to eq("Standard")
    end
  end

  context "with a previously published page that has been unpublished" do
    before do
      create(:alchemy_page, :public, page_layout: "standard", public_on: 1.day.ago, public_until: 1.minute.ago)
      render
    end

    it "counts it as draft" do
      standard_row = page.find("td.usage-stats--label", text: "Standard").ancestor("tr")
      tooltip = standard_row.find("td.usage-stats--bar sl-tooltip", visible: :all)
      expect(tooltip["content"]).to include("0 Published").and include("1 Draft")
    end
  end

  context "with a scheduled page" do
    before do
      create(:alchemy_page, :public, page_layout: "standard", public_on: 1.day.from_now)
      render
    end

    it "does not count it as published or draft" do
      standard_row = page.find("td.usage-stats--label", text: "Standard").ancestor("tr")
      tooltip = standard_row.find("td.usage-stats--bar sl-tooltip", visible: :all)
      expect(tooltip["content"]).to include("0 Published").and include("0 Draft")
    end
  end

  describe "performance" do
    before do
      create_list(:alchemy_page, 2, page_layout: "standard")
    end

    it "runs the published query at most twice per render" do
      allow(Alchemy::Page).to receive(:published).and_call_original
      render
      expect(Alchemy::Page).to have_received(:published).at_most(:twice)
    end

    it "loads page definitions only once per render" do
      allow(Alchemy::PageDefinition).to receive(:all).and_call_original
      render
      expect(Alchemy::PageDefinition).to have_received(:all).once
    end
  end
end
