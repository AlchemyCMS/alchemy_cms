# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::LocaleSelect, type: :component do
  subject! do
    expect(Alchemy::I18n).to receive(:available_locales) { locales }
    render
  end

  let(:render) { render_inline described_class.new }

  context "with one available locale" do
    let(:locales) { [:de] }

    it "should not render anything" do
      expect(rendered_content).to be_blank
    end
  end

  context "with many available locales" do
    let(:locales) { %i[de en] }

    it "should return a select with available locales with current locale selected" do
      expect(page).to have_selector("select[name='change_locale'] option[value='de'] + option[value='en'][selected]", text: "EN")
    end

    context "with name given" do
      let(:render) { render_inline described_class.new(:language) }

      it "should return a select with available locales with current locale selected" do
        expect(page).to have_selector("select[name='language']")
      end
    end
  end
end
