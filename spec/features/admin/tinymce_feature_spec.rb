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
    before do
      expect(ActionController::Base.config).to receive(:asset_host_set?).and_return(true)
    end

    it "base path should be set to tinymce asset folder" do
      visit admin_dashboard_path
      expect(page).to have_content(
        "var tinyMCEPreInit = { base: 'http://127.0.0.1/assets/tinymce', suffix: '.min' };",
      )
    end
  end
end
