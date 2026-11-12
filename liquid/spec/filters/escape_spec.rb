# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Alchemy::Liquid::Filters#escape", type: :helper do
  it "escapes plain strings" do
    expect(render_liquid("{{ value | escape }}", value: "<b>")).to eq("&lt;b&gt;")
  end

  it "does not double escape values already escaped by drops" do
    page = build_stubbed(:alchemy_page, name: "Tom & Jerry")
    expect(render_liquid("{{ page.name | escape }}|{{ page.name | h }}", page: page)).to eq("Tom &amp; Jerry|Tom &amp; Jerry")
  end
end
