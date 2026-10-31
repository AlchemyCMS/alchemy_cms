# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin main navigation" do
  before { authorize_user(:as_admin) }

  context "when the host app generates urls with a trailing slash" do
    around do |example|
      default_url_options = Alchemy::Engine.routes.default_url_options
      Alchemy::Engine.routes.default_url_options = default_url_options.merge(trailing_slash: true)
      example.run
    ensure
      Alchemy::Engine.routes.default_url_options = default_url_options
    end

    it "marks the entry of the current module as active" do
      get alchemy.admin_dashboard_path
      entry = Nokogiri::HTML(response.body).at_css("#main_navi .main_navi_entry:has(a[href^='/admin/dashboard'])")
      expect(entry["class"]).to include("active")
    end
  end

  context "when the host app adds content for :alchemy_main_navigation" do
    around do |example|
      original_view_paths = Alchemy::Admin::DashboardController.view_paths
      Alchemy::Admin::DashboardController.prepend_view_path(
        Alchemy::Engine.root.join("spec/fixtures/views/main_navigation_extension")
      )
      example.run
    ensure
      Alchemy::Admin::DashboardController.view_paths = original_view_paths
    end

    it "renders it inside the main navigation" do
      get alchemy.admin_dashboard_path
      expect(Nokogiri::HTML(response.body).css("#main_navi #host_app_entry")).to be_present
    end
  end
end
