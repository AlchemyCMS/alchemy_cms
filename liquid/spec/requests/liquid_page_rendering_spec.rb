# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Rendering a page with Liquid templates" do
  let(:page) { create(:alchemy_page, :public, page_layout: "everything", autogenerate_elements: false) }
  let!(:element) do
    create(:alchemy_element, :with_ingredients, name: "all_you_can_eat", page_version: page.public_version)
  end

  before do
    element.ingredient_by_role(:headline).update!(value: "Liquid works")
    element.ingredient_by_role(:text).update!(value: "<b>bold</b>")
  end

  it "renders the liquid page layout and element partial" do
    get "/#{page.urlname}"

    expect(response).to have_http_status(:ok)
    html = Nokogiri::HTML(response.body)
    expect(html.at_css("main.liquid-layout")["data-page"]).to eq(page.urlname)
    expect(html.at_css(".liquid-element .liquid-name").text).to eq("all_you_can_eat #1")
    expect(html.at_css(".liquid-element .headline h1").text).to include("Liquid works")
  end

  it "escapes text values from drops" do
    get "/#{page.urlname}"

    expect(response.body).to include("&lt;b&gt;bold&lt;/b&gt;")
    expect(response.body).not_to include("<b>bold</b>")
  end
end
