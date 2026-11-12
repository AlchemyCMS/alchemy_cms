# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Alchemy::Liquid::Filters#url", type: :helper do
  let(:page) { create(:alchemy_page, :public) }

  it "returns the url path of a page" do
    expect(render_liquid("{{ page | url }}", page: page)).to eq(page.url_path)
  end

  it "returns the url of a node" do
    node = build_stubbed(:alchemy_node, :with_url)
    expect(render_liquid("{{ node | url }}", node: node)).to eq("https://example.com")
  end

  it "returns the url path of a page ingredient" do
    ingredient = build_stubbed(:alchemy_ingredient_page, page: page)
    expect(render_liquid("{{ ingredient | url }}", ingredient: ingredient)).to eq(page.url_path)
  end

  it "returns the url of a node ingredient" do
    node = build_stubbed(:alchemy_node, :with_url)
    ingredient = build_stubbed(:alchemy_ingredient_node, node: node)
    expect(render_liquid("{{ ingredient | url }}", ingredient: ingredient)).to eq("https://example.com")
  end

  it "returns the value of a link ingredient" do
    ingredient = build_stubbed(:alchemy_ingredient_link, value: "/contact")
    expect(render_liquid("{{ ingredient | url }}", ingredient: ingredient)).to eq("/contact")
  end

  it "returns the link of a linkable ingredient" do
    ingredient = build_stubbed(:alchemy_ingredient_text, link: "/about")
    expect(render_liquid("{{ ingredient | url }}", ingredient: ingredient)).to eq("/about")
  end

  it "returns strings as they are" do
    expect(render_liquid('{{ "/foo" | url }}')).to eq("/foo")
  end

  it "returns nothing for other values" do
    expect(render_liquid("{{ 1 | url }}")).to eq("")
  end
end
