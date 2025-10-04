# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Picture Library", type: :system do
  before do
    authorize_user(:as_admin)
  end

  let!(:language) { create(:alchemy_language) }

  describe "Editing multiple pictures" do
    let!(:picture_1) { create(:alchemy_picture, name: "Picture 1") }
    let!(:picture_2) { create(:alchemy_picture, name: "Picture 2") }
    let!(:picture_3) { create(:alchemy_picture, name: "Picture 3") }

    scenario "allows to select multiple pictures and edit them", :js do
      visit alchemy.admin_pictures_path

      find("#picture_#{picture_1.id}").hover
      find("#picture_#{picture_1.id} .select > input[type='checkbox']").check
      find("#picture_#{picture_2.id}").hover
      find("#picture_#{picture_2.id} .select > input[type='checkbox']").check

      expect(page).to have_css(".selected_item_tools", visible: true)

      click_on "edit_multiple_pictures"

      within ".alchemy-dialog" do
        select2_search("newtag", from: "Tags")
        click_button "Save"
      end

      within "#flash_notices" do
        expect(page).to have_content("Pictures updated successfully")
      end

      [picture_1, picture_2].each do |picture|
        find("#picture_#{picture.id}").hover
        within "#picture_#{picture.id} .picture_tags" do
          expect(page).to have_content("newtag")
        end
      end
    end
  end

  describe "Editing multiple pictures" do
    let!(:picture_1) { create(:alchemy_picture, name: "Picture 1") }
    let!(:picture_2) { create(:alchemy_picture, name: "Picture 2") }
    let!(:picture_3) { create(:alchemy_picture, name: "Picture 3") }

    scenario "keeps existing params", :js do
      visit alchemy.admin_pictures_path(size: "large", q: {without_tag: 1})

      find("#picture_#{picture_1.id}").hover
      find("#picture_#{picture_1.id} .select > input[type='checkbox']").check
      find("#picture_#{picture_2.id}").hover
      find("#picture_#{picture_2.id} .select > input[type='checkbox']").check

      expect(page).to have_css(".selected_item_tools", visible: true)

      click_on "edit_multiple_pictures"

      within ".alchemy-dialog" do
        select2_search("newtag", from: "Tags")
        click_button "Save"
      end

      within "#flash_notices" do
        expect(page).to have_content("Pictures updated successfully")
      end

      # Pictures 1 and 2 should not be visible because of the without_tag filter
      expect(page).to_not have_selector("#picture_#{picture_2.id}")
      expect(page).to_not have_selector("#picture_#{picture_1.id}")

      expect(page).to have_selector("#picture_#{picture_3.id}")
    end
  end

  describe "Deleting multiple pictures" do
    let!(:picture_1) { create(:alchemy_picture, name: "Picture 1") }
    let!(:picture_2) { create(:alchemy_picture, name: "Picture 2") }
    let!(:picture_3) { create(:alchemy_picture, name: "Picture 3") }

    scenario "keeps existing params", :js do
      visit alchemy.admin_pictures_path(size: "large", q: {without_tag: 1})

      find("#picture_#{picture_1.id}").hover
      find("#picture_#{picture_1.id} .select > input[type='checkbox']").check
      find("#picture_#{picture_2.id}").hover
      find("#picture_#{picture_2.id} .select > input[type='checkbox']").check

      expect(page).to have_css(".selected_item_tools", visible: true)

      within ".selected_item_tools" do
        click_button "Delete"
      end

      within "sl-dialog" do
        click_button "Yes"
      end

      within "#flash_notices" do
        expect(page).to have_content("Pictures will be deleted now")
      end

      # Keeps existing params
      within "#filter_bar" do
        expect(page).to have_checked_field("Without tag")
      end
    end
  end

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

  describe "Filter by format" do
    let!(:picture1) { create(:alchemy_picture, name: "Ping", image_file: fixture_file_upload("image.png")) }
    let!(:picture2) { create(:alchemy_picture, name: "Jay Peg", image_file: fixture_file_upload("image3.jpeg")) }

    scenario "it's possible to filter pictures by format.", :js do
      visit alchemy.admin_pictures_path
      select2 "PNG", from: "File Type"
      within "#pictures" do
        expect(page).to have_content("Ping")
        expect(page).to_not have_content("Jay Peg")
      end
    end
  end

  describe "Sorting pictures", :js do
    let!(:picture_a) { create(:alchemy_picture, name: "A Picture", created_at: 2.days.ago) }
    let!(:picture_b) { create(:alchemy_picture, name: "B Picture", created_at: 1.day.ago) }

    scenario "it sorts pictures by latest by default." do
      visit alchemy.admin_pictures_path

      within "#pictures" do
        expect(page).to have_css("div.picture_thumbnail:nth-child(1) .picture_name", text: "B Picture")
        expect(page).to have_css("div.picture_thumbnail:nth-child(2) .picture_name", text: "A Picture")
      end
    end

    scenario "it's possible to sort pictures by name." do
      visit alchemy.admin_pictures_path

      select "A-Z", from: "Sorting"
      within "#pictures" do
        expect(page).to have_css("div.picture_thumbnail:nth-child(1) .picture_name", text: "A Picture")
        expect(page).to have_css("div.picture_thumbnail:nth-child(2) .picture_name", text: "B Picture")
      end
    end
  end

  describe "Picture descriptions", :js do
    let!(:picture) { create(:alchemy_picture) }

    scenario "allows to add a picture description" do
      visit alchemy.admin_pictures_path
      page.find("a.thumbnail_background").click
      expect(page).to have_field("Description")
      fill_in "Description", with: "This is an amazing image."
      click_button "Save"
      within "#flash_notices" do
        expect(page).to have_content("Picture updated successfully")
      end
      expect(picture.reload.description_for(language)).to eq("This is an amazing image.")
    end

    scenario "allows to add multi language picture descriptions" do
      german = create(:alchemy_language, :german)
      visit alchemy.admin_pictures_path
      page.find("a.thumbnail_background").click
      expect(page).to have_field("Description")
      fill_in "Description", with: "This is an amazing image."
      click_button "Save"
      within "#flash_notices" do
        expect(page).to have_content("Picture updated successfully")
      end

      select(german.language_code.upcase, from: "Language")
      fill_in "Description", with: "Tolles Bild."
      click_button "Save"
      within "#flash_notices" do
        expect(page).to have_content("Picture updated successfully")
      end

      select(language.language_code.upcase, from: "Language")
      expect(page).to have_field("Description", with: "This is an amazing image.")
      select(german.language_code.upcase, from: "Language")
      expect(page).to have_field("Description", with: "Tolles Bild.")
    end
  end

  describe "Updating Pictures", :js do
    let!(:picture) { create(:alchemy_picture) }

    scenario "allows to update a pictures name" do
      visit alchemy.admin_pictures_path
      page.find("a.thumbnail_background").click
      expect(page).to have_field("Name")
      fill_in "Name", with: "my-amazing-image"
      click_button "Save"
      within "#flash_notices" do
        expect(page).to have_content("Picture updated successfully")
      end
      find(".zoomed-picture-background").click
      within "#picture_#{picture.id} .picture_name" do
        expect(page).to have_content("my-amazing-image")
      end
    end
  end
end
