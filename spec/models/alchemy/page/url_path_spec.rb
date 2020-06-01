# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Page::UrlPath do
  subject(:url) { described_class.new(page).call }

  let(:site) { create(:alchemy_site) }

  context "if the page redirects to external" do
    let(:page) do
      create(:alchemy_page, page_layout: "external", site: site, urlname: "https://example.com")
    end

    it { is_expected.to eq("https://example.com") }
  end

  context "on a single language site" do
    context "for the language root page" do
      let(:page) { create(:alchemy_page, :language_root, site: site) }

      it { is_expected.to eq("/") }
    end

    context "for a regular page" do
      let(:page) { create(:alchemy_page, site: site) }

      it { is_expected.to eq("/#{page.urlname}") }
    end
  end

  context "on a multi language site" do
    let!(:default_language) { site.default_language }
    let!(:language) { create(:alchemy_language, :klingon, site: site) }

    context "for the language root page" do
      context "and page having the default language" do
        let(:page) do
          create(:alchemy_page, :language_root, site: site, language: default_language)
        end

        it { is_expected.to eq("/") }
      end

      context "and page having a non-default language" do
        let(:page) do
          create(:alchemy_page, :language_root, site: site, language: language)
        end

        it do
          is_expected.to eq("/#{page.language_code}")
        end
      end
    end

    context "for a regular page" do
      context "and page having the default language" do
        let(:page) do
          create(:alchemy_page, site: site, language: default_language)
        end

        it { is_expected.to eq("/#{page.urlname}") }
      end

      context "and page having a non-default language" do
        let(:page) do
          create(:alchemy_page, site: site, language: language)
        end

        it do
          is_expected.to eq("/#{page.language_code}/#{page.urlname}")
        end
      end
    end
  end
end
