# frozen_string_literal: true

require "rails_helper"

RSpec.describe "The Dashboard", type: :system do
  let(:user) { create(:alchemy_dummy_user, :as_editor, name: "Joe Editor") }

  before do
    authorize_user(user)
  end

  it "shows locked pages widget" do
    visit admin_dashboard_path
    expect(page).to have_css("#LockedPages")
  end

  it "shows recent pages widget" do
    visit admin_dashboard_path
    expect(page).to have_css("#RecentPages")
  end

  it "shows element usage widget" do
    visit admin_dashboard_path
    expect(page).to have_css("#ElementUsage")
  end

  it "shows page usage widget" do
    visit admin_dashboard_path
    expect(page).to have_css("#PageUsage")
  end

  it "shows the license with an icon and a dialog link" do
    visit admin_dashboard_path
    within(".system-info .license") do
      expect(page).to have_css("alchemy-icon[name='certificate-2']")
      link = find("a", text: "BSD-3-Clause")
      expect(link[:href]).to end_with(Alchemy::Engine.routes.url_helpers.dashboard_license_path)
    end
  end

  it "opens the LICENSE in a dialog", :js do
    visit admin_dashboard_path
    within(".system-info") { click_link("BSD-3") }
    within(".alchemy-dialog") do
      expect(page).to have_content("Redistribution and use in source and binary forms")
    end
  end

  context "with multiple sites" do
    let!(:default_site) { create(:alchemy_site, :default) }
    let!(:another_site) { create(:alchemy_site, name: "Site", host: "site.com") }

    it "shows sites widget" do
      visit admin_dashboard_path
      expect(page).to have_css("#Sites")
    end
  end

  context "with alchemy users" do
    before do
      allow(Alchemy.config.user_class).to receive(:logged_in) { [] }
    end

    it "shows online users widget" do
      visit admin_dashboard_path
      expect(page).to have_css("#OnlineUsers")
    end
  end

  context "with non alchemy user class" do
    before do
      stub_alchemy_config(user_class: "SomeUser")
    end

    it "does not show online users widget" do
      visit admin_dashboard_path
      expect(page).to_not have_css("#OnlineUsers")
    end
  end
end
