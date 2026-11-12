# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Liquid::Drops::PageDrop do
  let(:parent) { create(:alchemy_page, :language_root) }
  let(:page) do
    create(:alchemy_page, :public, parent: parent, name: "Tom & Jerry", urlname: "tom-jerry", page_layout: "standard")
  end

  before do
    allow(page).to receive(:meta_description).and_return("<desc>")
    allow(page).to receive(:meta_keywords).and_return("a, b")
  end

  subject(:drop) { described_class.new(page) }

  it "exposes curated page attributes" do
    expect(drop.id).to eq(page.id)
    expect(drop.name).to eq("Tom &amp; Jerry")
    expect(drop.title).to eq(ERB::Util.html_escape(page.title))
    expect(drop.urlname).to eq("tom-jerry")
    expect(drop.page_layout).to eq("standard")
    expect(drop.language_code).to eq(page.language_code)
    expect(drop.meta_description).to eq("&lt;desc&gt;")
    expect(drop.meta_keywords).to eq("a, b")
    expect(drop.published_at).to eq(page.published_at)
    expect(drop.public_on).to eq(page.public_on)
  end

  it "exposes the url path" do
    expect(drop.url).to eq(page.url_path)
  end

  it "exposes the parent as drop" do
    expect(drop.parent).to eq(described_class.new(parent))
  end

  it "does not expose other methods of the record" do
    expect(drop.invoke_drop("destroy")).to be_nil
    expect(drop.invoke_drop("record")).to be_nil
  end
end
