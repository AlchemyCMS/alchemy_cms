# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Liquid::Drops::NodeDrop do
  let(:root) { create(:alchemy_node, name: "Main & More", title: "Root", nofollow: true) }
  let!(:child) { create(:alchemy_node, :with_url, parent: root, external: true) }

  subject(:drop) { described_class.new(root) }

  it "exposes curated node attributes" do
    expect(drop.id).to eq(root.id)
    expect(drop.name).to eq("Main &amp; More")
    expect(drop.title).to eq("Root")
    expect(drop.nofollow).to be(true)
    expect(drop.external).to be(false)
    expect(drop.menu_type).to eq(root.menu_type)
  end

  it "exposes the children as drops" do
    expect(drop.children).to eq([described_class.new(child)])
    expect(drop.children.first.url).to eq("https://example.com")
    expect(drop.children.first.external).to be(true)
  end

  context "with a page attached" do
    let(:root) { create(:alchemy_node, :with_page) }

    it "exposes the page and its url" do
      expect(drop.page).to eq(Alchemy::Liquid::Drops::PageDrop.new(root.page))
      expect(drop.url).to eq(root.page.url_path)
    end
  end
end
