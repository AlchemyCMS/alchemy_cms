require 'spec_helper'

describe 'Locale select' do
  let(:a_page) { FactoryGirl.create(:public_page) }
  before do
    Alchemy::I18n.stub(translation_files: ['alchemy.kl.yml', 'alchemy.jp.yml', 'alchemy.cz.yml'])
    authorize_as_admin
  end

  it "contains all locales in a selectbox" do
    visit admin_dashboard_path
    expect(page).to have_select('change_locale', options: ['Kl', 'Jp', 'Cz'])
  end

  context 'when having available_locales set for Alchemy::I18n' do
    before { Alchemy::I18n.stub(available_locales: [:jp, :cz]) }
    it "provides only that locales" do
      visit admin_dashboard_path
      expect(page).to have_select('change_locale', options: ['Jp', 'Cz'])
    end
  end
end
