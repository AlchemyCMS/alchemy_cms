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
