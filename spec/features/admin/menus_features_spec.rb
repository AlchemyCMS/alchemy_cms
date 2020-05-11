# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin Menus Features", type: :system do
  before do
    authorize_user(:as_admin)
  end

  describe "adding a new menu" do
    context "on the index page" do
      let!(:default_language) { create(:alchemy_language) }

      it "creates menu" do
        visit alchemy.admin_nodes_path

        select "Main Menu", from: "Menu Type"
        click_button "create"

        expect(page).to have_selector(".node_name", text: "Main Menu")
      end
    end
  end

  describe "adding a new menu" do
    context "with multiple sites" do
      let!(:default_site) { create(:alchemy_site, :default) }
      let!(:default_language) { create(:alchemy_language, site: default_site) }
      let!(:site_2) { create(:alchemy_site, host: "another-site.com") }
      let!(:site_2_language) { create(:alchemy_language, site: site_2) }
      let(:node) { Alchemy::Node.last }

      it "creates menu for current site" do
        visit alchemy.new_admin_node_path

        select "Main Menu", from: "Menu Type"
        click_button "create"

        expect(node.site).to eq(default_site)
      end
    end
  end
end
