# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Picture assignment overlay", type: :system do
  before do
    authorize_user(:as_admin)
  end

  describe "assigning an image" do
    let!(:picture) { create(:alchemy_picture) }
    let(:element) { create(:alchemy_element, :with_ingredients, name: "header") }
    let(:ingredient) { element.ingredients.last }

    scenario "it has a button to assign picture to ingredient" do
      visit alchemy.admin_pictures_path(form_field_id: "ingredients_#{ingredient.id}_picture_id")
      expect(page).to have_css %(form[action*="/admin/pictures/#{picture.id}/assign"] button[type="submit"])
      expect(page).to have_css %(form[action*="/admin/pictures/#{picture.id}/assign"] input[name="_method"][value="put"]), visible: :hidden
    end

    scenario "thumbnail renders at the selected size" do
      expect(Alchemy::Admin::PictureThumbnail).to receive(:new)
        .with(picture, size: "large").and_call_original
      visit alchemy.admin_pictures_path(
        form_field_id: "ingredients_#{ingredient.id}_picture_id",
        size: "large"
      )
    end

    context "in the picture editor", :js do
      # The default factory image is 1x1px, too small to click reliably.
      let!(:picture) { create(:alchemy_picture, image_file: fixture_file_upload("500x500.png")) }
      let(:assign_requests) { Queue.new }

      around do |example|
        subscriber = ActiveSupport::Notifications.subscribe("process_action.action_controller") do |*, payload|
          assign_requests << payload if payload[:action] == "assign"
        end
        example.run
        ActiveSupport::Notifications.unsubscribe(subscriber)
      end

      scenario "assigns the picture to the ingredient" do
        visit alchemy.admin_elements_path(page_version_id: element.page_version_id)

        within "#element_#{element.id}" do
          find("a[href*='/admin/pictures']").click
        end
        within ".alchemy-dialog" do
          find("#assignable_#{picture.id} alchemy-picture-thumbnail").click
        end

        expect(page).to have_no_css(".alchemy-dialog")
        expect(page).to have_css("#element_#{element.id}.dirty alchemy-picture-thumbnail img")
        expect(find("[data-picture-id]", visible: :hidden).value).to eq(picture.id.to_s)
      end

      scenario "double clicking a picture only assigns it once" do
        visit alchemy.admin_elements_path(page_version_id: element.page_version_id)

        within "#element_#{element.id}" do
          find("a[href*='/admin/pictures']").click
        end
        within ".alchemy-dialog" do
          find("#assignable_#{picture.id} alchemy-picture-thumbnail").double_click
        end

        expect(page).to have_no_css(".alchemy-dialog")
        expect(page).to have_css("#element_#{element.id}.dirty alchemy-picture-thumbnail img")
        expect(assign_requests.size).to eq(1)
      end
    end
  end

  describe "filtering the picture list" do
    let!(:picture) { create(:alchemy_picture, name: "Blue Jeans") }
    let!(:picture2) { create(:alchemy_picture, name: "Kittens") }
    let(:element) { create(:alchemy_element, :with_ingredients, name: "header") }
    let(:ingredient) { element.ingredients.last }

    scenario "by name reduces the list" do
      visit alchemy.admin_pictures_path(form_field_id: "ingredients_#{ingredient.id}_picture_id")
      within "#resource_search" do
        if Alchemy.storage_adapter.dragonfly?
          fill_in "q[image_file_name_or_name_cont]", with: "Blue"
        elsif Alchemy.storage_adapter.active_storage?
          fill_in "q[image_file_blob_filename_or_name_cont]", with: "Blue"
        end
        find("button[type='submit']").click
      end
      within "#assign_image_list" do
        expect(page).to have_content "Blue Jeans"
        expect(page).to_not have_content "Kittens"
      end
    end
  end
end
