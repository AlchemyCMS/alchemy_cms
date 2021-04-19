# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Picture assignment overlay", type: :system do
  before do
    authorize_user(:as_admin)
  end

  describe "assigning an image" do
    let!(:picture) { create(:alchemy_picture) }
    let(:element) { create(:alchemy_element, :with_contents, name: "header") }
    let(:content) { element.contents.last }

    scenario "it has link to assign picture to content" do
      visit alchemy.admin_pictures_path(form_field_id: "contents_#{content.id}_picture_id")
      expect(page).to have_css %(a[data-method="put"][href*="/admin/pictures/#{picture.id}/assign"])
    end
  end
end
