# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Requests for PagesController#sitemap" do
  let!(:page) { create(:alchemy_page, :public, sitemap: true) }

  it "renders valid xml sitemap" do
    get "/sitemap.xml"
    expect(response.media_type).to eq("application/xml")
    xml_doc = Nokogiri::XML(response.body)
    expect(xml_doc.namespaces).to have_key("xmlns")
    expect(xml_doc.namespaces["xmlns"]).to eq("http://www.sitemaps.org/schemas/sitemap/0.9")
    expect(xml_doc.css("urlset url loc").length).to eq(2)
  end

  it "lastmod dates are ISO 8601 timestamps" do
    get "/sitemap.xml"
    expect(response.media_type).to eq("application/xml")
    xml_doc = Nokogiri::XML(response.body)
    xml_doc.css("urlset url lastmod").each do |timestamps|
      expect(timestamps.text).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/)
    end
  end

  context "in multi language mode" do
    let!(:klingon) { create(:alchemy_language, :klingon) }
    let!(:klingon_page) { create(:alchemy_page, :public, sitemap: true, language: klingon) }

    it "links in sitemap has locale code included" do
      get "/sitemap.xml"
      xml_doc = Nokogiri::XML(response.body)
      klingon_loc = xml_doc.css("urlset url loc").map(&:text).find { |loc| loc.include?(klingon_page.urlname) }
      expect(klingon_loc).to match(/\/#{klingon.language_code}\//)
    end

    context "if the default locale is the page locale" do
      it "links in sitemap has no locale code included" do
        get "/sitemap.xml"
        xml_doc = Nokogiri::XML(response.body)
        default_loc = xml_doc.css("urlset url loc").map(&:text).find { |loc| loc.include?(page.urlname) }
        expect(default_loc).to_not match(/\/#{page.language_code}\//)
      end
    end
  end
end
