# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Nodes management", type: :system, js: true do
  before do
    authorize_user(:as_admin)
  end

  let!(:a_page) { create(:alchemy_page) }
  let!(:a_menu) { create(:alchemy_node, name: "Menu") }

  def open_page_properties
    visit admin_pages_path
    expect(page.find("alchemy-overlay")).to_not have_css(".visible")
    page.find("a[href='#{configure_admin_page_path(a_page)}']", wait: 10).click
    find("[panel='nodes']").click
  end

  def add_menu_item
    find("#new_node_form .select2-choice").click
    find(".select2-result:first-child").click

    click_button "Add a menu node"
  end

  it "lets a user add a menu node" do
    open_page_properties
    add_menu_item

    within "#page_nodes table" do
      expect(page).to have_content("Menu node Menu / A Page 1")
    end
    within "[panel='nodes']" do
      expect(page).to have_content("(1) Menu node")
    end
  end

  context "without parent id" do
    it "displays error message" do
      open_page_properties

      click_button "Add a menu node"
      within ".flash.error" do
        expect(page).to have_content("Menu Type can't be blank")
      end
    end
  end

  context "with menu node present" do
    before do
      open_page_properties
      add_menu_item
    end

    it "lets a user remove a menu node" do
      page.accept_alert "Do you really want to delete this menu node?" do
        click_link_with_tooltip("Delete this menu node")
      end

      within "#page_nodes table" do
        expect(page).to_not have_content("Menu node Menu / A Page 1")
        expect(page).to have_content(Alchemy.t("No menu node for this page found"))
      end
      within "[panel='nodes']" do
        expect(page).to have_content("(0) Menu nodes")
      end
    end
  end
end
