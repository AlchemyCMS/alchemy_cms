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

    context "with pages", :js do
      let(:default_language) { create(:alchemy_language) }
      let!(:contentpage) { create(:alchemy_page, language: default_language) }
      let!(:layoutpage) { create(:alchemy_page, :layoutpage, language: default_language) }
      let!(:main_menu) { create(:alchemy_node, name: "Main Menu") }

      it "can assign contentpages" do
        visit alchemy.admin_nodes_path
        expect(page).to have_selector(".node_name", text: "Main Menu")
        within ".nodes_tree" do
          click_link_with_tooltip Alchemy.t(:create_node)
        end
        within ".alchemy-dialog" do
          select2_search contentpage.name, from: "Page"
          click_button "create"
        end
        expect(page).to have_selector(".node_name", text: contentpage.name)
      end

      it "can not assign layoutpages" do
        visit alchemy.admin_nodes_path
        expect(page).to have_selector(".node_name", text: "Main Menu")
        within ".nodes_tree" do
          click_link_with_tooltip Alchemy.t(:create_node)
        end
        within ".alchemy-dialog" do
          select2_search layoutpage.name, from: "Page", select: false
        end
        within ".select2-results" do
          expect(page).to have_content("No matches found")
        end
      end
    end

    context "without pages", :js do
      let!(:main_menu) { create(:alchemy_node, name: "Main Menu") }

      it "can add node with absolute url path" do
        visit alchemy.admin_nodes_path
        expect(page).to have_selector(".node_name", text: "Main Menu")
        within ".nodes_tree" do
          click_link_with_tooltip Alchemy.t(:create_node)
        end
        within ".alchemy-dialog" do
          fill_in "Name", with: "Internal Link"
          fill_in "URL", with: "/custom-url"
          click_button "create"
        end
        expect(page).to have_selector(".node_name", text: "/custom-url")
      end

      it "can add node with full external url" do
        visit alchemy.admin_nodes_path
        expect(page).to have_selector(".node_name", text: "Main Menu")
        within ".nodes_tree" do
          click_link_with_tooltip Alchemy.t(:create_node)
        end
        within ".alchemy-dialog" do
          fill_in "Name", with: "External Link"
          fill_in "URL", with: "https://example.com/index.php?page=123"
          click_button "create"
        end
        expect(page).to have_selector(".node_name", text: "https://example.com/index.php?page=123")
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
