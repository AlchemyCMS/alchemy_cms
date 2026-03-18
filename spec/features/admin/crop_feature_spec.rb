# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Image Cropper", type: :system do
  before do
    authorize_user(:as_admin)
  end

  let(:element) { create(:alchemy_element, name: "all_you_can_eat") }
  let(:picture) { create(:alchemy_picture) }
  let(:ingredient) do
    create(:alchemy_ingredient_picture, element: element, picture: picture)
  end

  it "renders image cropper settings as valid JavaScript" do
    visit alchemy.crop_admin_ingredient_path(ingredient, picture_id: picture.id)
    expect(page).to have_content("new ImageCropper(image, {")
  end
end
