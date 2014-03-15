require 'spec_helper'

module Alchemy
  describe BaseController do

    describe '#set_locale' do
      context 'with Language.current set' do
        let(:language) { create(:klingonian) }

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

  end
end
