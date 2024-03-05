# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Current do
  describe ".site" do
    context "when site is set" do
      let(:site) { build(:alchemy_site, host: "example.com") }

      before do
        Alchemy::Current.site = site
      end

      it "should return current site" do
        expect(Alchemy::Current.site).to eq(site)
      end
    end

    context "when set to nil" do
      let!(:site) { create(:alchemy_site, host: "example.com") }

      before do
        Alchemy::Current.site = nil
      end

      it "should return first site" do
        expect(Alchemy::Current.site).not_to be_nil
        expect(Alchemy::Current.site).to eq(Alchemy::Site.first)
      end
    end
  end

  describe ".language" do
    context "when site is set" do
      let(:language) { build(:alchemy_language) }

      before do
        Alchemy::Current.language = language
      end

      it "should return current language" do
        expect(Alchemy::Current.language).to eq(language)
      end
    end

    context "when set to nil" do
      let!(:language) { create(:alchemy_language, default: true) }

      before do
        Alchemy::Current.language = nil
      end

      it "should return default language" do
        expect(Alchemy::Current.language).not_to be_nil
        expect(Alchemy::Current.language).to eq(Alchemy::Language.default)
      end
    end
  end

  describe ".preview_page=" do
    let(:site) { build(:alchemy_site) }
    let(:language) { build(:alchemy_language, site: site) }
    let(:page) { build(:alchemy_page, language: language) }

    it "stores page as current preview page" do
      described_class.preview_page = page
      expect(described_class.preview_page).to eq(page)
    end

    it "stores page as current page" do
      described_class.preview_page = page
      expect(described_class.page).to eq(page)
    end

    it "stores pages language as current language" do
      described_class.preview_page = page
      expect(described_class.language).to eq(language)
    end

    it "stores pages site as current site" do
      described_class.preview_page = page
      expect(described_class.site).to eq(site)
    end

    context "with page being nil" do
      it "removes page as current preview page" do
        described_class.preview_page = nil
        expect(described_class.preview_page).to be_nil
      end

      it "removes page as current page" do
        described_class.preview_page = nil
        expect(described_class.page).to be_nil
      end

      it "removes pages language as current language" do
        described_class.preview_page = nil
        expect(described_class.language).to be_nil
      end

      it "removes pages site as current site" do
        described_class.preview_page = nil
        expect(described_class.site).to be_nil
      end
    end
  end

  describe ".preview_page?" do
    context "with Current.page being Current.preview_page" do
      it "returns true" do
        page = build_stubbed(:alchemy_page)
        described_class.preview_page = page
        described_class.page = page
        expect(described_class.preview_page?).to be_truthy
      end
    end

    context "with page being Current.preview_page" do
      it "returns true" do
        page = build_stubbed(:alchemy_page)
        described_class.preview_page = page
        expect(described_class.preview_page?(page)).to be_truthy
      end
    end

    context "with page not being Current.preview_page" do
      it "returns false" do
        described_class.preview_page = build_stubbed(:alchemy_page)
        page = build_stubbed(:alchemy_page)
        expect(described_class.preview_page?(page)).to be_falsey
      end
    end

    context "with Current.page not being Current.preview_page" do
      it "returns false" do
        described_class.preview_page = build_stubbed(:alchemy_page, id: 2)
        described_class.page = build_stubbed(:alchemy_page, id: 1)
        expect(described_class.preview_page?).to be_falsey
      end
    end

    context "with preview_page being nil" do
      it "returns false" do
        described_class.preview_page = nil
        described_class.page = build_stubbed(:alchemy_page, id: 1)
        expect(described_class.preview_page?).to be_falsey
      end
    end
  end
end
