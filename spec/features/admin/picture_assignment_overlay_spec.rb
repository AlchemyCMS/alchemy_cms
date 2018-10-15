# frozen_string_literal: true

require 'spec_helper'

RSpec.feature "Picture assignment overlay" do
  before do
    authorize_user(:as_admin)
  end

  describe "filter by tags", js: true do
    let!(:a_page) { create(:alchemy_page, do_not_autogenerate: false) }
    let!(:pic1) { create(:alchemy_picture, name: "Hill", tag_list: "landscape") }
    let!(:pic2) { create(:alchemy_picture, name: "Skyscraper", tag_list: "city") }

    scenario "shows only the pictures tagged with the selected tag" do
      visit alchemy.edit_admin_page_path(a_page)

      within "#element_area div[data-element-name='article']" do
        click_on "Insert image"
      end

      within ".alchemy-dialog.modal" do
        # We expect to see both pictures
        expect(page).to have_selector("#overlay_picture_list a img", count: 2, wait: 10)

        # Click on a tag to filter the pictures
        within ".tag-list" do
          click_on "landscape (1)"
        end

        # We expect to see only the picture tagged with 'landscape'.
        expect(page).to have_selector("#overlay_picture_list a img", count: 1)
        expect(page).to have_selector("#overlay_picture_list a img[alt='Hill']")
      end
    end
  end

  describe "assigning an image" do
    let!(:picture) { create(:alchemy_picture) }
    let(:element) { create(:alchemy_element, :with_contents, name: 'header') }
    let(:content) { element.contents.last }

    scenario 'it has link to assign picture to content' do
      visit alchemy.admin_pictures_path(content_id: content.id)
      expect(page).to have_css('a[data-method="put"][href*="/admin/essence_pictures/assign"]')
    end
  end
end
