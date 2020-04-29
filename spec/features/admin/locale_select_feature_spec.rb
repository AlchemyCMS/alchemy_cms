# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Locale select", type: :system do
  let(:a_page) { create(:alchemy_page, :public) }

  before do
    allow(Alchemy::I18n).to receive(:translation_files).and_return ["alchemy.kl.yml", "alchemy.jp.yml", "alchemy.cz.yml"]
    authorize_user(:as_admin)
  end

  it "contains all locales in a selectbox" do
    visit admin_dashboard_path
    expect(page).to have_select("change_locale", options: ["Kl", "Jp", "Cz"])
  end

  context "when having available_locales set for Alchemy::I18n" do
    before do
      allow(Alchemy::I18n).to receive(:available_locales).and_return [:jp, :cz]
    end

    it "provides only these locales" do
      visit admin_dashboard_path
      expect(page).to have_select("change_locale", options: ["Jp", "Cz"])
    end
  end

  describe "user selects locale" do
    context "that is available" do
      before do
        allow(Alchemy::I18n).to receive(:available_locales).and_return [:kl]
      end

      it "switches the locale" do
        visit admin_dashboard_path(admin_locale: "kl")
        expect(page).to have_content("majQa' Dub")
      end
    end

    context "that is not available" do
      it "does not switch the locale" do
        visit admin_dashboard_path(admin_locale: "de")
        expect(page).to have_content("Welcome back")
      end
    end
  end
end
