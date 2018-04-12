# frozen_string_literal: true

require 'spec_helper'

describe 'Locale select' do
  let(:a_page) { create(:alchemy_page, :public) }
  before do
    allow(Alchemy::I18n).to receive(:translation_files).and_return ['alchemy.kl.yml', 'alchemy.jp.yml', 'alchemy.cz.yml']
    authorize_user(:as_admin)
  end

  it "contains all locales in a selectbox" do
    visit admin_dashboard_path
    expect(page).to have_select('change_locale', options: ['Kl', 'Jp', 'Cz'])
  end

  context 'when having available_locales set for Alchemy::I18n' do
    before do
      allow(Alchemy::I18n).to receive(:available_locales).and_return [:jp, :cz]
    end

    it "provides only that locales" do
      visit admin_dashboard_path
      expect(page).to have_select('change_locale', options: ['Jp', 'Cz'])
    end
  end
end
