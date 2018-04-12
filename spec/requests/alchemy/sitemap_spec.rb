# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Requests for PagesController#sitemap' do
  let!(:page) { create(:alchemy_page, :public, sitemap: true) }

  it 'renders valid xml sitemap' do
    get '/sitemap.xml'
    expect(response.content_type).to eq('application/xml')
    xml_doc = Nokogiri::XML(response.body)
    expect(xml_doc.namespaces).to have_key('xmlns')
    expect(xml_doc.namespaces['xmlns']).to eq('http://www.sitemaps.org/schemas/sitemap/0.9')
    expect(xml_doc.css('urlset url loc').length).to eq(2)
  end

  it 'lastmod dates are ISO 8601 timestamps' do
    get '/sitemap.xml'
    expect(response.content_type).to eq('application/xml')
    xml_doc = Nokogiri::XML(response.body)
    xml_doc.css('urlset url lastmod').each do |timestamps|
      expect(timestamps.text).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z/)
    end
  end

  context 'in multi language mode' do
    let!(:root) { page.parent }
    let!(:pages) { [root, page] }

    before do
      allow_any_instance_of(Alchemy::BaseController).to receive('prefix_locale?') { true }
    end

    it 'links in sitemap has locale code included' do
      get '/sitemap.xml'
      xml_doc = Nokogiri::XML(response.body)
      xml_doc.css('urlset url').each_with_index do |node, i|
        page = pages[i]
        expect(node.css('loc').text).to match(/\/#{page.language_code}\//)
      end
    end

    context 'if the default locale is the page locale' do
      before do
        allow_any_instance_of(Alchemy::BaseController).to receive('prefix_locale?') { false }
      end

      it 'links in sitemap has no locale code included' do
        get '/sitemap.xml'
        xml_doc = Nokogiri::XML(response.body)
        xml_doc.css('urlset url').each_with_index do |node, i|
          page = pages[i]
          expect(node.css('loc').text).to_not match(/\/#{page.language_code}\//)
        end
      end
    end
  end
end
