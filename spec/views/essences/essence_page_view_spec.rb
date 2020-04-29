# frozen_string_literal: true

require "rails_helper"

describe "alchemy/essences/_essence_page_view" do
  let(:page) { build(:alchemy_page, urlname: "a-page") }
  let(:essence) { Alchemy::EssencePage.new(page: page) }
  let(:content) { Alchemy::Content.new(essence: essence) }

  context "without page" do
    let(:essence) { Alchemy::EssencePage.new }

    it "renders nothing" do
      render content, content: content
      expect(rendered).to eq("")
    end
  end

  context "with page" do
    it "renders a link to the page" do
      render content, content: content
      expect(rendered).to have_selector("a[href='/#{page.urlname}']")
    end

    it "has the page name as link text" do
      render content, content: content
      expect(rendered).to have_selector("a:contains('#{page.name}')")
    end
  end
end
