# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin main navigation" do
  before { authorize_user(:as_admin) }

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
