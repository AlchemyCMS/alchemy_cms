# encoding: UTF-8
require 'spec_helper'

module Alchemy
  describe Language do
    let(:default_language) { Alchemy::Language.default }
    let(:language)         { create(:alchemy_language, :klingonian) }
    let(:page)             { create(:alchemy_page, language: language) }

    it "should return a label for code" do
      expect(language.label(:code)).to eq('kl')
    end

    it "should return a label for name" do
      expect(language.label(:name)).to eq('Klingonian')
    end

    context "with language_code and empty country_code" do
      it "#code should return language locale only" do
        language.country_code = ''
        expect(language.code).to eq('kl')
      end

      context "adding a value for country code" do
        it "#code should return a joined locale" do
          language.country_code = 'cr'
          expect(language.code).to eq('kl-cr')
        end

        it "should update all associated Pages with self.code as value for Page#language_code" do
          page = create(:alchemy_page, language: language)
          language.country_code = 'cr'
          language.save
          page.reload; expect(page.language_code).to eq('kl-cr')
        end
      end
    end

    context "with country_code and_language_code" do
      context "removing the country_code" do
        it "should update all associated Pages´s language_code with Language#code" do
          language = create(:alchemy_language, country_code: 'kl')
          language.country_code = ''
          language.save
          page.reload; expect(page.language_code).to eq("kl")
        end
      end
    end

    it "should not be deletable if it is the default language" do
      expect {
        default_language.destroy
      }.to raise_error(DefaultLanguageNotDeletable)
    end

    describe "before save" do
      describe "#remove_old_default if default attribute has changed to true" do
        it "should unset the default status of the old default language" do
          default_language
          language.update_attributes(default: true)
          default_language.reload
          expect(default_language.default).to be_falsey
        end
      end
    end

    context "after_update" do
      describe "#set_pages_language if language´s code has changed" do
        it "should update all its pages with the new code" do
          @other_page = create(:alchemy_page, language: language)
          language.update_attributes(code: "fo")
          language.reload; page.reload; @other_page.reload
          expect([page.language_code, @other_page.language_code]).to eq([language.code, language.code])
        end
      end

      describe "#unpublish_pages" do
        it "should set all pages to unpublic if it gets set to unpublic" do
          page = create(:alchemy_page, language: language)
          @other_page = create(:alchemy_page, language: language)
          language.update_attributes(public: false)
          language.reload; page.reload; @other_page.reload
          expect([page.public?, @other_page.public?]).to eq([false, false])
        end
      end
    end

    describe '.find_by_code' do
      context "with only the language code given" do
        it "should find the language" do
          expect(Language.find_by_code(language.code)).to eq(language)
        end
      end
    end

    context 'validations' do
      let(:language) { Language.new(default: true, public: false) }

      describe 'publicity_of_default_language' do
        context 'if language is not published' do
          it "should add an error to the object" do
            expect(language.valid?).to eq(false)
            expect(language.errors.messages).to have_key(:public)
          end
        end
      end

      describe 'presence_of_default_language' do
        context 'if no default language would exist anymore' do
          before do
            allow(Language).to receive(:default).and_return(language)
            allow(language).to receive(:default_changed?).and_return(true)
          end

          it "should add an error to the object" do
            expect(language.valid?).to eq(false)
            expect(language.errors.messages).to have_key(:default)
          end
        end
      end
    end
  end
end
