# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Requesting a page" do
  let!(:default_language) { create(:alchemy_language, :english, default: true) }

  let!(:default_language_root) do
    create(:alchemy_page, :language_root, language: default_language, name: "Home")
  end

  let(:public_page) do
    create(:alchemy_page, :public, name: "Page 1")
  end

  context "in multi language mode" do
    let(:second_page) { create(:alchemy_page, :public, name: "Second Page") }

    let(:legacy_url) do
      Alchemy::LegacyPageUrl.create(
        urlname: "index.php?option=com_content&view=article&id=48&Itemid=69",
        page: second_page,
      )
    end

    before do
      allow_any_instance_of(Alchemy::PagesController).to receive(:multi_language?).and_return(true)
    end

    context "if language params are given" do
      context "and page locale is default locale" do
        it "redirects to unprefixed locale url" do
          allow(::I18n).to receive(:default_locale) { public_page.language_code.to_sym }
          visit("/#{public_page.language_code}/#{public_page.urlname}")
          expect(page.current_path).to eq("/#{public_page.urlname}")
        end
      end

      context "and page locale is not default locale" do
        it "does not redirect" do
          allow(::I18n).to receive(:default_locale).and_return(:de)
          visit("/#{public_page.language_code}/#{public_page.urlname}")
          expect(page.current_path).to eq("/#{public_page.language_code}/#{public_page.urlname}")
        end
      end
    end

    context "if no language params are given" do
      context "and page locale is default locale" do
        it "doesn't prepend the url with the locale string" do
          allow(::I18n).to receive(:default_locale) { public_page.language_code.to_sym }
          visit("/#{public_page.urlname}")
          expect(page.current_path).to eq("/#{public_page.urlname}")
        end

        it "redirects legacy url with unknown format & query string without locale prefix" do
          allow(::I18n).to receive(:default_locale) { second_page.language_code.to_sym }
          visit "/#{legacy_url.urlname}"
          uri = URI.parse(page.current_url)
          expect(uri.query).to be_nil
          expect(uri.request_uri).to eq("/#{second_page.urlname}")
        end
      end

      context "and page locale is not default locale" do
        before do
          allow(::I18n).to receive(:default_locale).and_return(:de)
        end

        it "redirects to url with the locale prefixed" do
          visit("/#{public_page.urlname}")
          expect(page.current_path).to eq("/en/#{public_page.urlname}")
        end

        it "redirects legacy url with unknown format & query string with locale prefix" do
          visit "/#{legacy_url.urlname}"
          uri = URI.parse(page.current_url)
          expect(uri.query).to be_nil
          expect(uri.request_uri).to eq("/en/#{second_page.urlname}")
        end
      end
    end

    context "if requested page is unpublished" do
      before do
        create(:alchemy_page, name: "Not Public")
      end

      it "should raise not found error" do
        expect {
          visit "/not-public"
        }.to raise_error(ActionController::RoutingError)
      end
    end

    context "if requested url is only the language code" do
      context "if requested locale is the default locale" do
        before do
          allow(::I18n).to receive(:default_locale) { default_language.code }
        end

        it "redirects to '/'" do
          visit "/#{default_language.code}"
          expect(page.current_path).to eq("/")
        end
      end

      context "if page locale is not the default locale" do
        before do
          allow(::I18n).to receive(:default_locale) { :de }
        end

        it "does not redirect" do
          visit "/#{default_language.code}"
          expect(page.current_path).to eq("/#{default_language.code}")
        end
      end
    end

    it "should keep additional params" do
      visit "/#{public_page.urlname}?query=Peter"
      expect(page.current_url).to match(/\?query=Peter/)
    end

    context "wrong language requested" do
      before do
        allow(Alchemy.user_class).to receive(:admins).and_return([1, 2])
      end

      it "should render 404 if urlname and lang parameter do not belong to same page" do
        create(:alchemy_language, :klingon)
        expect {
          visit "/kl/#{public_page.urlname}"
        }.to raise_error(ActionController::RoutingError)
      end

      it "should render 404 if requested language does not exist" do
        public_page
        Alchemy::LegacyPageUrl.delete_all
        expect {
          visit "/fo/#{public_page.urlname}"
        }.to raise_error(ActionController::RoutingError)
      end
    end
  end

  context "not in multi language mode" do
    let(:second_page) { create(:alchemy_page, :public, name: "Second Page") }

    let(:legacy_url) do
      Alchemy::LegacyPageUrl.create(
        urlname: "index.php?option=com_content&view=article&id=48&Itemid=69",
        page: second_page,
      )
    end

    before do
      allow_any_instance_of(Alchemy::PagesController).to receive(:multi_language?).and_return(false)
    end

    it "redirects legacy url with unknown format & query string" do
      visit "/#{legacy_url.urlname}"
      uri = URI.parse(page.current_url)
      expect(uri.query).to be_nil
      expect(uri.request_uri).to eq("/#{second_page.urlname}")
    end

    it "redirects from nested language code url to normal url" do
      visit "/en/#{public_page.urlname}"
      expect(page.current_path).to eq("/#{public_page.urlname}")
    end

    context "if requested url is index url" do
      context "when locale is prefixed" do
        it "redirects to normal url" do
          visit "/en"
          expect(page.current_path).to eq("/")
        end
      end
    end

    it "should keep additional params" do
      visit "/en/#{public_page.urlname}?query=Peter"
      expect(page.current_url).to match(/\?query=Peter/)
    end
  end
end
