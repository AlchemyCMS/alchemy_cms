# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::ListFilter, type: :component do
  it "renders alchemy-list-filter element" do
    render_inline(described_class.new(".items"))
    expect(page).to have_css("alchemy-list-filter")
  end

  it "renders the items-selector attribute" do
    render_inline(described_class.new(".items"))
    expect(page).to have_css('alchemy-list-filter[items-selector=".items"]')
  end

  it "renders name-attribute defaulting to 'name'" do
    render_inline(described_class.new(".items"))
    expect(page).to have_css('alchemy-list-filter[name-attribute="name"]')
  end

  it "renders custom name-attribute" do
    render_inline(described_class.new(".items", name_attribute: "filter-text"))
    expect(page).to have_css('alchemy-list-filter[name-attribute="filter-text"]')
  end

  it "renders the search input" do
    render_inline(described_class.new(".items"))
    expect(page).to have_css('input[type="text"]')
  end

  it "renders the clear button" do
    render_inline(described_class.new(".items"))
    expect(page).to have_css('button[type="button"]')
  end

  context "with placeholder" do
    it "renders the placeholder" do
      render_inline(described_class.new(".items", placeholder: "Search items"))
      expect(page).to have_css('input[placeholder="Search items"]')
    end
  end

  context "with hotkey" do
    it "renders the hotkey attribute" do
      render_inline(described_class.new(".items", hotkey: "alt+f"))
      expect(page).to have_css('alchemy-list-filter[hotkey="alt+f"]')
    end
  end

  context "without hotkey" do
    it "does not render hotkey attribute" do
      render_inline(described_class.new(".items"))
      expect(page).not_to have_css("alchemy-list-filter[hotkey]")
    end
  end
end
