require 'spec_helper'

describe 'TinyMCE Editor' do

  before do
    authorize_user(:as_admin)
  end

  it 'base path should be set to tinymce asset folder' do
    visit admin_dashboard_path
    expect(page).to have_content <<-TINYMCE
var tinyMCEPreInit = {
  base: '/assets/tinymce',
  suffix: '.min'
};
TINYMCE
  end

  context 'with asset host' do
    before do
      expect(ActionController::Base.config).to receive(:asset_host_set?).and_return(true)
    end

    it 'base path should be set to tinymce asset folder' do
      visit admin_dashboard_path
      expect(page).to have_content <<-TINYMCE
var tinyMCEPreInit = {
  base: 'http://www.example.com/assets/tinymce',
  suffix: '.min'
};
TINYMCE
    end
  end
end
