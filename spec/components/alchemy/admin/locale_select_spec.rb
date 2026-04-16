# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::LocaleSelect, type: :component do
  subject! do
    expect(Alchemy::I18n).to receive(:available_locales) { locales }
    allow(vc_test_view_context).to receive(:url_for) { "/admin/dashboard" }
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
      expect(page).to have_selector("select[name='admin_locale'] option[value='de'] + option[value='en'][selected]", text: "EN")
    end

    context "with name given" do
      let(:render) { render_inline described_class.new(:language) }

      it "should return a select with available locales with current locale selected" do
        expect(page).to have_selector("select[name='language']")
      end
    end

    it "should return a select with auto submit wrapper" do
      expect(page).to have_selector("alchemy-auto-submit select[name='admin_locale']")
    end

    context "with auto_submit false" do
      let(:render) { render_inline described_class.new(:admin_locale, auto_submit: false) }

      it "should return a select without auto submit wrapper" do
        expect(page).not_to have_selector("alchemy-auto-submit")
        expect(page).to have_selector("select[name='admin_locale']")
      end
    end
  end
end
