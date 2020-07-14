# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Site editing feature", type: :system do
  before { authorize_user(:as_admin) }

  it "can create a new page" do
    visit alchemy.new_admin_site_path
    fill_in "site_host", with: "api.example.com"
    fill_in "site_name", with: "API Site"
    click_button "Save"
    expect(page).to have_content "You need at least one language to work with. Please create one below."
    visit alchemy.edit_admin_site_path(Alchemy::Site.first)
    fill_in "Aliases", with: "api.localhost"
    click_button "Save"
    expect(page).to have_content "api.localhost"
  end
end
