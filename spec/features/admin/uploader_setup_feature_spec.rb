# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Uploader setup", type: :system do
  before do
    authorize_user(:as_admin)
  end

  it "renders uploader defaults as valid JavaScript" do
    visit admin_dashboard_path
    expect(page).to have_content("Alchemy.uploader_defaults = {")
  end
end
