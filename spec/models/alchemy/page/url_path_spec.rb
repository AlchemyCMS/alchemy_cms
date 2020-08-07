# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Page::UrlPath do
  subject(:url) { described_class.new(page).call }

  let(:site) { create(:alchemy_site) }

  context "on a single language site" do
    context "for the language root page" do
      let(:page) { create(:alchemy_page, :language_root) }

      it { is_expected.to eq("/") }
    end

    context "for a regular page" do
      let(:page) { create(:alchemy_page) }

      it { is_expected.to eq("/#{page.urlname}") }
    end
  end

  context "on a multi language site" do
    let!(:default_language) { create(:alchemy_language, site: site) }
    let!(:language) { create(:alchemy_language, :klingon, site: site) }

    context "for the language root page" do
      context "and page having the default language" do
        let(:page) do
          create(:alchemy_page, :language_root, language: default_language)
        end

        it { is_expected.to eq("/") }
      end

      context "and page having a non-default language" do
        let(:page) do
          create(:alchemy_page, :language_root, language: language)
        end

        it do
          is_expected.to eq("/#{page.language_code}")
        end
      end
    end

    context "for a regular page" do
      context "and page having the default language" do
        let(:page) do
          create(:alchemy_page, language: default_language)
        end

        it { is_expected.to eq("/#{page.urlname}") }
      end

      context "and page having a non-default language" do
        let(:page) do
          create(:alchemy_page, language: language)
        end

        it do
          is_expected.to eq("/#{page.language_code}/#{page.urlname}")
        end
      end
    end
  end

  context "mounted on a non-root path" do
    let(:page) do
      create(:alchemy_page)
    end

    before do
      expect(Alchemy::Engine.routes).to receive(:url_helpers) do
        double(root_path: "/pages/")
      end
    end

    it "prefixes the path" do
      is_expected.to eq("/pages/#{page.urlname}")
    end
  end
end
