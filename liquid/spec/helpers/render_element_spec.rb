# frozen_string_literal: true

require "rails_helper"

RSpec.describe "render_element with a Liquid partial", type: :helper do
  let(:page) { create(:alchemy_page, :public, autogenerate_elements: false) }
  let(:element) do
    create(:alchemy_element, :with_ingredients, name: "all_you_can_eat", page_version: page.public_version)
  end

  before do
    Alchemy::Current.page = page
    helper.instance_variable_set(:@page, page)
  end

  subject(:html) { Nokogiri::HTML.fragment(helper.render_element(element, {}, 3)) }

  it "renders the .html.liquid partial with the element and counter locals" do
    expect(html.at_css(".liquid-name").text).to eq("all_you_can_eat #3")
  end

  it "wraps the content with element_view_for" do
    expect(html.at_css("div.liquid-element .liquid-name")).to be_present
  end

  context "in preview mode" do
    before { Alchemy::Current.preview_page = page }

    it "adds the preview attributes to the wrapper" do
      expect(html.at_css("div.liquid-element")["data-alchemy-element"]).to eq(element.id.to_s)
    end
  end

  it "renders ingredient view components" do
    element.ingredient_by_role(:headline).update!(value: "Hello")
    expect(html.at_css(".headline h1").text).to include("Hello")
  end
end
