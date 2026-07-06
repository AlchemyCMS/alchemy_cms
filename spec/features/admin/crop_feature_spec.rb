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

  it "renders the image cropper with its settings" do
    visit alchemy.crop_admin_ingredient_path(ingredient, picture_id: picture.id)
    expect(page).to have_css("alchemy-image-cropper[default-box] img[src]", visible: :all)
  end

  context "in the crop dialog", :js do
    let(:element) { create(:alchemy_element, name: "article") }

    let(:picture) do
      create(:alchemy_picture, image_file: fixture_file_upload("500x500.png")).tap do |picture|
        # The active_storage picture factory hard codes the metadata dimensions
        # to 1x1; dragonfly derives them from the actual image file.
        if Alchemy.storage_adapter.name == :active_storage
          blob = picture.image_file.blob
          blob.update!(metadata: blob.metadata.merge(width: 500, height: 500))
        end
      end
    end

    let!(:ingredient) do
      create(:alchemy_ingredient_picture, element: element, picture: picture, role: "image")
    end

    def crop_from_field
      find("[data-crop-from]", visible: :hidden)
    end

    def crop_size_field
      find("[data-crop-size]", visible: :hidden)
    end

    it "allows cropping the image with the graphical cropper" do
      visit alchemy.admin_elements_path(page_version_id: element.page_version_id)
      find("a.crop_link").click

      within ".alchemy-dialog" do
        # cropperjs builds its crop box once the image is ready.
        expect(page).to have_css(".cropper-container .cropper-crop-box")
        click_button "Reset mask"
      end

      # Resetting writes the centered default mask into the form fields.
      expect(crop_from_field.value).to eq("0x83")
      expect(crop_size_field.value).to eq("500x333")

      within ".alchemy-dialog" do
        click_button "apply"
      end

      expect(page).to have_no_css(".alchemy-dialog")

      # Applying stores the mask in image coordinates. Since the mask was not
      # touched after resetting, the default box is stored (within rounding).
      crop_from = crop_from_field.value.split("x").map(&:to_i)
      crop_size = crop_size_field.value.split("x").map(&:to_i)
      expect(crop_from[0]).to be_within(2).of(0)
      expect(crop_from[1]).to be_within(2).of(83)
      expect(crop_size[0]).to be_within(2).of(500)
      expect(crop_size[1]).to be_within(2).of(333)
    end
  end
end
