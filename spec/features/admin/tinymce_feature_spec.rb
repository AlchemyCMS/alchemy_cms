# frozen_string_literal: true

require "rails_helper"

RSpec.describe "TinyMCE Editor", type: :system do
  before do
    authorize_user(:as_admin)
  end

  it "base path should be set to tinymce asset folder" do
    visit admin_dashboard_path
    expect(page).to have_content(
      "var tinyMCEPreInit = { base: '/assets/tinymce', suffix: '.min' };",
    )
  end

  context "with asset host" do
    around do |example|
      host = ActionController::Base.config.asset_host
      ActionController::Base.config.asset_host = "myhost.com"
      example.run
      ActionController::Base.config.asset_host = host
    end

    it "base path should be set to tinymce asset folder" do
      visit admin_dashboard_path
      expect(page).to have_content(
        "var tinyMCEPreInit = { base: 'http://myhost.com/assets/tinymce', suffix: '.min' };",
      )
    end
  end
end
