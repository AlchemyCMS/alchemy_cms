# frozen_string_literal: true

require "rails_helper"

RSpec.describe "alchemy/ingredients/_page_view" do
  let(:page) { build(:alchemy_page, urlname: "a-page") }
  let(:ingredient) { Alchemy::Ingredients::Page.new(page: page) }

  context "without page" do
    let(:ingredient) { Alchemy::Ingredients::Page.new }

    it "renders nothing" do
      render ingredient
      expect(rendered).to eq("")
    end
  end

  context "with page" do
    it "renders a link to the page" do
      render ingredient
      expect(rendered).to have_selector("a[href='/#{page.urlname}']")
    end

    it "has the page name as link text" do
      render ingredient
      expect(rendered).to have_selector("a:contains('#{page.name}')")
    end
  end
end
