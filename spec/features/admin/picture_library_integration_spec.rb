# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Picture Library", type: :system do
  before do
    authorize_user(:as_admin)
  end

  let!(:language) { create(:alchemy_language) }

  describe "Tagging" do
    let!(:picture_1) { create(:alchemy_picture, tag_list: "tag1", name: "TaggedWith1") }
    let!(:picture_2) { create(:alchemy_picture, tag_list: "tag2", name: "TaggedWith2") }

    scenario "it's possible to filter tags by clicking on its name in the tag list." do
      visit alchemy.admin_pictures_path

      click_on "tag1 (1)"

      expect(page).to have_content("TaggedWith1")
      expect(page).not_to have_content("TaggedWith2")
    end

    scenario "it's possible to undo tag filtering by clicking on an active tag name" do
      visit alchemy.admin_pictures_path

      click_on "tag1 (1)"

      expect(page).to have_content("TaggedWith1")
      expect(page).not_to have_content("TaggedWith2")

      click_on "tag1 (1)"

      expect(page).to have_content("TaggedWith1")
      expect(page).to have_content("TaggedWith2")
    end

    scenario "it's possible to tighten the tag scope by clicking on another tag name." do
      visit alchemy.admin_pictures_path

      click_on "tag1 (1)"
      click_on "tag2 (1)"

      expect(page).to have_content("You don't have any images in your archive")
    end
  end

  describe "Filter by tag" do
    let!(:picture) { create(:alchemy_picture, tag_list: "bla") }

    scenario "lists all applied tags." do
      visit alchemy.admin_pictures_path

      expect(page).to have_content("bla")
    end

    scenario "it's possible to filter pictures by tag." do
      visit alchemy.admin_pictures_path

      click_on "bla (1)"

      expect(page).to have_content("bla")
    end
  end

  describe "Picture descriptions" do
    let!(:picture) { create(:alchemy_picture) }

    scenario "allows to add a picture description", :js do
      visit alchemy.admin_pictures_path
      page.find("a.thumbnail_background").click
      expect(page).to have_field("Description")
      fill_in "Description", with: "This is an amazing image."
      click_button "Save"
      within "#flash_notices" do
        expect(page).to have_content("Picture updated successfully")
      end
      expect(picture.description_for(language)).to eq("This is an amazing image.")
    end

    scenario "allows to add multi language picture descriptions", :js do
      german = create(:alchemy_language, :german)
      visit alchemy.admin_pictures_path
      page.find("a.thumbnail_background").click
      expect(page).to have_field("Description")
      select(german.language_code.upcase, from: "Language")
      fill_in "Description", with: "Tolles Bild."
      click_button "Save"
      within "#flash_notices" do
        expect(page).to have_content("Picture updated successfully")
      end
      expect(picture.description_for(german)).to eq("Tolles Bild.")
    end
  end
end
