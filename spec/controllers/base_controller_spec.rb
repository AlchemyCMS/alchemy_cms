require 'spec_helper'

module Alchemy
  describe BaseController do

    describe '#set_locale' do
      context 'with Language.current set' do
        let(:language) { create(:alchemy_language, :klingonian) }

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
      context "if more than one published language exists" do
        it "returns true" do
          allow(Alchemy::Language).to receive(:published).and_return double(count: 2)
          expect(controller.multi_language?).to eq(true)
        end
      end

      context "if less than two published languages exists" do
        it "returns false" do
          allow(Alchemy::Language).to receive(:published).and_return double(count: 1)
          expect(controller.multi_language?).to eq(false)
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
