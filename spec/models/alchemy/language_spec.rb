# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe Language do
    it { is_expected.to have_many(:nodes) }
    it { is_expected.to have_one(:root_page) }

    let(:default_language) { create(:alchemy_language) }
    let(:language)         { create(:alchemy_language, :klingon) }
    let(:page)             { create(:alchemy_page, language: language) }

    it "is valid with uppercase country code" do
      language = Alchemy::Language.new(
        country_code: "AT",
        language_code: "de",
        name: "Österreich",
        frontpage_name: "Start",
        page_layout: "index",
        site: build(:alchemy_site),
      )
      expect(language).to be_valid
    end

    it "should return a label for code" do
      expect(language.label(:code)).to eq("kl")
    end

    it "should return a label for name" do
      expect(language.label(:name)).to eq("Klingon")
    end

    context "with language_code and empty country_code" do
      it "#code should return language locale only" do
        language.country_code = ""
        expect(language.code).to eq("kl")
      end

      context "adding a value for country code" do
        it "#code should return a joined locale" do
          language.country_code = "cr"
          expect(language.code).to eq("kl-cr")
        end

        it "should update all associated Pages with self.code as value for Page#language_code" do
          page = create(:alchemy_page, language: language)
          language.country_code = "cr"
          language.save
          page.reload; expect(page.language_code).to eq("kl-cr")
        end
      end
    end

    context "with country_code and_language_code" do
      context "removing the country_code" do
        it "should update all associated Pages´s language_code with Language#code" do
          language = create(:alchemy_language, country_code: "kl")
          language.country_code = ""
          language.save
          page.reload; expect(page.language_code).to eq("kl")
        end
      end
    end

    describe "before save" do
      describe "#remove_old_default if default attribute has changed to true" do
        it "should unset the default status of the old default language" do
          default_language
          language.update(default: true)
          default_language.reload
          expect(default_language.default).to be_falsey
        end
      end
    end

    context "after_update" do
      describe "#set_pages_language if language´s code has changed" do
        it "should update all its pages with the new code" do
          @other_page = create(:alchemy_page, language: language)
          language.update(code: "fo")
          language.reload; page.reload; @other_page.reload
          expect([page.language_code, @other_page.language_code]).to eq([language.code, language.code])
        end
      end
    end

    describe ".default" do
      let!(:site_1) do
        create(:alchemy_site, host: "site-one.com")
      end

      let!(:site_2) do
        create(:alchemy_site, host: "site-two.com")
      end

      let!(:default_language) do
        site_2.default_language
      end

      subject do
        Language.default
      end

      it "returns the default language of current site" do
        expect(Site).to receive(:current) { site_2 }
        is_expected.to eq(default_language)
      end
    end

    describe ".find_by_code" do
      subject do
        Language.find_by_code(code)
      end

      let(:code) do
        language.language_code
      end

      it "should find the language by language code" do
        is_expected.to eq(language)
      end

      context "with language code and country code given" do
        let(:code) do
          "#{language.language_code}-#{language.country_code}"
        end

        it "should find the language" do
          is_expected.to eq(language)
        end
      end

      context "with multiple sites having languages with same code" do
        let!(:default_site) { create(:alchemy_site, :default) }

        let!(:current_site) do
          create(:alchemy_site, host: "other.com")
        end

        let!(:other_language) do
          create(:alchemy_language, site: current_site, code: language.code)
        end

        before do
          expect(Site).to receive(:current) { current_site }
        end

        it "loads the language from current site" do
          is_expected.to eq(other_language)
        end
      end
    end

    describe "validations" do
      let(:language) { Language.new(default: true, public: false) }

      describe "publicity_of_default_language" do
        context "if language is not published" do
          it "should add an error to the object" do
            expect(language.valid?).to eq(false)
            expect(language.errors.messages).to have_key(:public)
          end
        end
      end

      describe "presence_of_default_language" do
        context "if no default language would exist anymore" do
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

      describe "before" do
        subject do
          language.valid?
          language.locale
        end

        before do
          allow(::I18n).to receive(:available_locales) do
            [:de, :'de-at', :en, :'en-uk']
          end
        end

        context "when locale is already set" do
          let(:language) do
            build(:alchemy_language, language_code: "de", locale: "de")
          end

          it "does not set the locale again" do
            expect(language).to_not receive(:set_locale)
          end
        end

        context "when code is an available locale" do
          let(:language) do
            build(:alchemy_language, language_code: "de", country_code: "at")
          end

          it "sets the locale to code" do
            is_expected.to eq("de-at")
          end
        end

        context "when code is not is an available locale, but language_code is" do
          let(:language) do
            build(:alchemy_language, language_code: "de", country_code: "ch")
          end

          it "sets the locale to language code" do
            is_expected.to eq("de")
          end
        end

        context "when language_code is an available locale" do
          let(:language) do
            build(:alchemy_language, language_code: "en")
          end

          it "sets the locale to language_code" do
            is_expected.to eq("en")
          end
        end

        context "when neither language_code nor code is an available locale" do
          it { is_expected.to be_nil }
        end
      end

      describe "presence_of_locale_file" do
        context "when locale file is missing for selected language code" do
          let(:language) do
            build(:alchemy_language, language_code: "jp")
          end

          it "adds errors to locale attribute" do
            expect(language).to_not be_valid
            expect(language.errors).to have_key(:locale)
          end
        end

        context "when locale file is present for selected language code" do
          let(:language) do
            build(:alchemy_language, :klingon)
          end

          it "adds no errors to locale attribute" do
            expect(language).to be_valid
            expect(language.errors).to_not have_key(:locale)
          end
        end
      end
    end

    describe "#matching_locales" do
      let(:language) do
        build(:alchemy_language, language_code: "de")
      end

      subject do
        language.matching_locales
      end

      before do
        expect(::I18n).to receive(:available_locales).twice do
          [:de, :'de-at', :'en-uk']
        end
      end

      it "returns locales matching the language code" do
        is_expected.to eq [:de, :'de-at']
      end

      context "when language code is not is an available locale" do
        let(:language) do
          build(:alchemy_language, language_code: "jp")
        end

        it { is_expected.to eq [] }
      end
    end

    describe "#destroy" do
      let(:language) { create(:alchemy_language) }

      subject { language.destroy }

      context "without pages" do
        it "works" do
          subject
          expect(language.errors[:pages]).to be_empty
        end
      end

      context "with pages" do
        let!(:page) { create(:alchemy_page, language: language) }

        it "must not work" do
          subject
          expect(language.errors[:pages]).to_not be_empty
        end
      end
    end
  end
end
