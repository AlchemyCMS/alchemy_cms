# frozen_string_literal: true

require 'spec_helper'

module Alchemy
  describe BaseController do
    describe '#set_locale' do
      context 'with Language.current set' do
        let(:language) { create(:alchemy_language, :klingon) }

        before { Alchemy::Language.current = language }

        it "sets the ::I18n.locale to current language code" do
          controller.send(:set_locale)
          expect(::I18n.locale).to eq(language.code.to_sym)
        end
      end

      context 'without Language.current set' do
        before { Alchemy::Language.current = nil }

        it "sets the ::I18n.locale to default language code" do
          controller.send(:set_locale)
          expect(::I18n.locale).to eq(Language.default.code.to_sym)
        end
      end
    end

    describe "#configuration" do
      it "returns certain configuration options" do
        allow(Config).to receive(:show).and_return({"some_option" => true})
        expect(controller.configuration(:some_option)).to eq(true)
      end
    end

    describe "#multi_language?" do
      subject { controller.multi_language? }

      context "if less than two published languages exists" do
        it { is_expected.to be(false) }
      end

      context "if more than one published language exists" do
        let!(:language_2) do
          create(:alchemy_language, :klingon)
        end

        it { is_expected.to be(true) }
      end

      context "for multiple sites" do
        let!(:default_site) { create(:alchemy_site, :default) }

        let!(:site_2) do
          create(:alchemy_site, host: 'another-host.com')
        end

        let!(:site_2_language_2) do
          create(:alchemy_language, :klingon, site: site_2)
        end

        it 'only is true for current site' do
          is_expected.to be(false)
        end
      end
    end

    describe "#prefix_locale?" do
      subject(:prefix_locale?) { controller.prefix_locale? }

      context "if multi_language? is true" do
        before do
          expect(controller).to receive(:multi_language?) { true }
        end

        context "and current language is not the default locale" do
          before do
            allow(Alchemy::Language).to receive(:current) { double(code: 'en') }
            allow(::I18n).to receive(:default_locale) { :de }
          end

          it { expect(prefix_locale?).to be(true) }
        end

        context "and current language is the default locale" do
          before do
            allow(Alchemy::Language).to receive(:current) { double(code: 'de') }
            allow(::I18n).to receive(:default_locale) { :de }
          end

          it { expect(prefix_locale?).to be(false) }
        end

        context "and passed in locale is not the default locale" do
          subject(:prefix_locale?) { controller.prefix_locale?('en') }

          before do
            allow(::I18n).to receive(:default_locale) { :de }
          end

          it { expect(prefix_locale?).to be(true) }
        end

        context "and passed in locale is the default locale" do
          subject(:prefix_locale?) { controller.prefix_locale?('de') }

          before do
            allow(::I18n).to receive(:default_locale) { :de }
          end

          it { expect(prefix_locale?).to be(false) }
        end
      end

      context "if multi_language? is false" do
        before do
          expect(controller).to receive(:multi_language?) { false }
        end

        it { expect(prefix_locale?).to be(false) }
      end
    end
  end
end
