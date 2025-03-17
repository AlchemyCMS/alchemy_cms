# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::LinkDialog::InternalTab, type: :component do
  let(:site) { create(:alchemy_site) }
  let(:language) { create(:alchemy_language, site: site, default: true, code: "en") }
  let(:url) { "/homepage#bar" }

  let!(:alchemy_page) { create(:alchemy_page, urlname: "homepage", language: language, language_code: "en") }

  let(:is_selected) { false }
  let(:link_title) { nil }
  let(:link_target) { nil }

  before do
    Alchemy::Current.site = site
    render_inline(described_class.new(url, is_selected: is_selected, link_title: link_title, link_target: link_target))
  end

  it_behaves_like "a link dialog tab", :internal, "Internal"
  it_behaves_like "a link dialog - target select", :internal

  context "with page found by url" do
    it "has url value set" do
      expect(page.find(:css, "input[name=internal_link]").value).to eq("/homepage#bar")
    end

    context "with trailing slash" do
      let(:url) { "/homepage/#bar" }

      it "has url value set" do
        expect(page.find(:css, "input[name=internal_link]").value).to eq("/homepage/#bar")
      end

      it "has hash fragment set" do
        expect(page.find(:css, "select[name=element_anchor]").value).to eq("#bar")
      end
    end

    it "has hash fragment set" do
      expect(page.find(:css, "select[name=element_anchor]").value).to eq("#bar")
    end

    context "with locale in url" do
      let(:url) { "/en/homepage" }

      it "has url value set" do
        expect(page.find(:css, "input[name=internal_link]").value).to eq("/en/homepage")
      end

      context "with trailing slash" do
        let(:url) { "/en/homepage/" }

        it "has url value set" do
          expect(page.find(:css, "input[name=internal_link]").value).to eq("/en/homepage/")
        end
      end
    end

    context "with root url" do
      let(:url) { alchemy_page && "/" }

      it "has url value set to root url" do
        expect(page.find(:css, "input[name=internal_link]").value).to eq("/")
      end
    end

    context "with locale root url" do
      let(:url) { "/en" }

      it "has url value set to root url" do
        expect(page.find(:css, "input[name=internal_link]").value).to eq("/en")
      end

      context "with trailing slash" do
        let(:url) { "/en/" }

        it "has url value set to root url" do
          expect(page.find(:css, "input[name=internal_link]").value).to eq("/en/")
        end
      end
    end
  end

  context "with page not found by url" do
    let(:url) { "/foo" }

    it "has no url value set" do
      expect(page.find(:css, "input[name=internal_link]").value).to be_nil
    end

    it "has no hash fragment set" do
      expect(page.find(:css, "select[name=element_anchor]").value).to be_empty
    end
  end

  context "with url being mailto" do
    let(:url) { "mailto:foo@example.com" }

    it do
      expect { page }.to_not raise_error
    end
  end
end
