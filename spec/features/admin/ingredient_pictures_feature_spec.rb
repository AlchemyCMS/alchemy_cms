require "rails_helper"

RSpec.feature "Ingredient Pictures admin feature", type: :system do
  before do
    authorize_user(:as_editor)
  end

  let(:language) { create(:alchemy_language) }
  let(:element) { create(:alchemy_element, name: "all_you_can_eat") }
  let(:picture) { create(:alchemy_picture) }
  let(:ingredient_picture) { create(:alchemy_ingredient_picture, picture: picture, element: element) }

  describe "picture description" do
    let!(:picture_description) do
      Alchemy::PictureDescription.create!(picture: picture, language: language, text: "A nice picture")
    end

    scenario "Picture description is used as default for ingredient picture alt text" do
      visit alchemy.edit_admin_ingredient_path(ingredient_picture)
      expect(page).to have_field("Alternative text", placeholder: "A nice picture")
    end
  end

  scenario "Picture css class can be selected by editor" do
    visit alchemy.edit_admin_ingredient_path(ingredient_picture)
    expect(page).to have_select("Style")
  end
end
