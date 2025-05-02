# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::PageView, type: :component do
  let(:alchemy_page) { build(:alchemy_page, urlname: "a-page") }
  let(:ingredient) { Alchemy::Ingredients::Page.new(page: alchemy_page) }

  context "without page" do
    let(:ingredient) { Alchemy::Ingredients::Page.new }

    it "renders nothing" do
      render_inline described_class.new(ingredient)
      expect(page).to have_content("")
    end
  end

  context "with page" do
    it "renders a link to the page" do
      render_inline described_class.new(ingredient)
      expect(page).to have_selector("a[href='/#{alchemy_page.urlname}']")
    end

    it "has the page name as link text" do
      render_inline described_class.new(ingredient)
      expect(page).to have_selector("a:contains('#{alchemy_page.name}')")
    end
  end
end
