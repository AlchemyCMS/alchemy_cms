require 'spec_helper'

describe 'TinyMCE Editor' do
  let(:user) { DummyUser.new }

  before do
    user.update(alchemy_roles: %w(admin), name: "Joe User", id: 1)
    authorize_as_admin(user)
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
