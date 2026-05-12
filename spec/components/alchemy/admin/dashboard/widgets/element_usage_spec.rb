# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::Dashboard::Widgets::ElementUsage, type: :component do
  subject(:render) { render_inline(described_class.new) }

  let(:definition_count) { Alchemy::ElementDefinition.all.size }

  context "without any elements" do
    before { render }

    it "renders a row for each defined element" do
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

  context "with published elements of different names" do
    before do
      create_list(:alchemy_element, 3, name: "article", public: true)
      create(:alchemy_element, name: "headline", public: true)
      render
    end

    it "still renders a row for each defined element" do
      expect(page).to have_selector("table.usage-stats tr", count: definition_count)
    end

    it "renders the total count of published elements" do
      expect(page).to have_selector("aside", text: "4")
    end

    it "sorts used elements by count descending before unused ones" do
      counts = page.all("td.usage-stats--value:last-child").map(&:text).map(&:strip)
      expect(counts.first(2)).to eq(["3", "1"])
      expect(counts.drop(2).uniq).to eq(["0"])
    end

    it "renders the percentage for each row" do
      percentages = page.all("td.usage-stats--value:first-of-type").map(&:text).map(&:strip)
      expect(percentages.first(2)).to eq(["75.00%", "25.00%"])
    end

    it "sets the largest bar to 100% width" do
      expect(page.first("span.bar")["style"]).to include("width: 100.0%")
    end
  end

  context "with both published and draft-only elements" do
    before do
      create_list(:alchemy_element, 2, name: "article", public: true)
      create(:alchemy_element, name: "article", public_on: nil)
      render
    end

    it "shows the combined public + draft count in the header total" do
      expect(page).to have_selector("aside", text: "3")
    end

    it "shows the combined count in the value column" do
      counts = page.all("td.usage-stats--value:last-child").map(&:text).map(&:strip)
      expect(counts.first).to eq("3")
    end

    it "renders a stacked bar with both a public and a draft segment" do
      first_bar = page.first("span.bar")
      public_segment = first_bar.find("span.bar__public", visible: :all)
      draft_segment = first_bar.find("span.bar__draft", visible: :all)
      expect(public_segment["style"]).to include("width: 66.67%")
      expect(draft_segment["style"]).to include("width: 33.33%")
    end

    it "mentions both counts in the combined sl-tooltip" do
      tooltip = page.first("td.usage-stats--bar").find("sl-tooltip", visible: :all)
      expect(tooltip["content"]).to include("2 Published").and include("1 Draft")
    end
  end

  context "with a draft element on a page that has already been published" do
    let!(:public_page) do
      create(:alchemy_page, :public).tap do |p|
        create(:alchemy_element, name: "article", public_on: Time.current, page_version: p.public_version)
        create(:alchemy_element, name: "article", public_on: nil, page_version: p.draft_version)
      end
    end

    before { render }

    it "still counts the working copy in the draft segment" do
      first_bar = page.first("span.bar")
      expect(first_bar.find("span.bar__public", visible: :all)["style"]).to include("width: 50.0%")
      expect(first_bar.find("span.bar__draft", visible: :all)["style"]).to include("width: 50.0%")
    end
  end

  context "with a previously published element that has been unpublished" do
    before do
      create(:alchemy_element, name: "article", public_on: 1.day.ago, public_until: 1.minute.ago)
      render
    end

    it "counts it as draft" do
      first_bar = page.first("span.bar")
      expect(first_bar.find("span.bar__draft", visible: :all)["style"]).to include("width: 100.0%")
      tooltip = page.first("td.usage-stats--bar").find("sl-tooltip", visible: :all)
      expect(tooltip["content"]).to include("0 Published").and include("1 Draft")
    end
  end

  context "with a scheduled element" do
    before do
      create(:alchemy_element, name: "article", public_on: 1.day.from_now)
      render
    end

    it "does not count it as published" do
      expect(page).to have_selector("aside", text: "0")
    end

    it "does not count it as draft either" do
      first_bar = page.first("span.bar")
      expect(first_bar["style"]).to include("width: 0%")
      tooltip = page.first("td.usage-stats--bar").find("sl-tooltip", visible: :all)
      expect(tooltip["content"]).to include("0 Published").and include("0 Draft")
    end
  end

  context "for any element row" do
    before do
      create(:alchemy_element, name: "article", public: true)
      render
    end

    it "renders the definition's icon" do
      expect(page).to have_selector("td.usage-stats--label svg")
    end
  end

  describe "performance" do
    before do
      create_list(:alchemy_element, 2, name: "article", public: true)
      create(:alchemy_element, name: "headline", public: true)
    end

    it "runs the count query only once per render" do
      allow(Alchemy::Element).to receive(:published).and_call_original
      render
      expect(Alchemy::Element).to have_received(:published).once
    end

    it "loads element definitions only once per render" do
      allow(Alchemy::ElementDefinition).to receive(:all).and_call_original
      render
      expect(Alchemy::ElementDefinition).to have_received(:all).once
    end
  end
end
