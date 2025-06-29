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

    scenario "it has link to assign picture to ingredient" do
      visit alchemy.admin_pictures_path(form_field_id: "ingredients_#{ingredient.id}_picture_id")
      expect(page).to have_css %(a[data-method="put"][href*="/admin/pictures/#{picture.id}/assign"])
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
          fill_in "q[name_or_image_file_name_cont]", with: "Blue"
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
