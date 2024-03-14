require "rails_helper"

RSpec.feature "Ingredient Pictures admin feature", type: :system do
  before do
    authorize_user(:as_editor)
  end

  let(:language) { create(:alchemy_language) }
  let(:picture) { create(:alchemy_picture) }
  let(:ingredient_picture) { create(:alchemy_ingredient_picture, picture: picture) }

  let!(:picture_description) do
    Alchemy::PictureDescription.create!(picture: picture, language: language, text: "A nice picture")
  end

  scenario "Picture description is used as default for ingredient picture alt text" do
    visit alchemy.edit_admin_ingredient_path(ingredient_picture)
    expect(page).to have_field("Alternative text", placeholder: "A nice picture")
  end
end
