require "rails_helper"

RSpec.describe Alchemy::Admin::TagsAutocomplete, type: :component do
  before do
    render
  end

  context "without parameters" do
    subject(:render) do
      render_inline(described_class.new) { "Page Select Content" }
    end

    it "should render the component and render given block content" do
      expect(page).to have_selector("alchemy-tags-autocomplete")
      expect(page).to have_text("Page Select Content")
    end

    it "should have the default placeholder" do
      expect(page).to have_selector("alchemy-tags-autocomplete[placeholder='Search tag']")
    end

    it "should have the default tags autocomplete - url" do
      expect(page).to have_selector("alchemy-tags-autocomplete[url='/admin/tags/autocomplete']")
    end
  end

  context "with additional class" do
    subject(:render) do
      render_inline(described_class.new(additional_class: "foooo"))
    end

    it "should have these class" do
      expect(page).to have_selector("alchemy-tags-autocomplete.foooo")
    end
  end
end
