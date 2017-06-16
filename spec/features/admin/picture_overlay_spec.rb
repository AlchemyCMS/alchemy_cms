require 'spec_helper'

RSpec.feature "Picture overlay" do
  before do
    authorize_user(:as_admin)
  end

  let(:element) { create(:alchemy_element) }

  describe "filter by tags", js: true do
    let!(:a_page) { create(:alchemy_page, do_not_autogenerate: false) }
    let!(:pic1) { create(:alchemy_picture, name: "Hill", tag_list: "landscape") }
    let!(:pic2) { create(:alchemy_picture, name: "Skyscraper", tag_list: "city") }

    scenario "shows only the pictures tagged with the selected tag" do
      pending("Buggy at the moment. Fix is not implemented yet")

      visit alchemy.edit_admin_page_path(a_page)

      within "#element_area div[data-element-name='article']" do
        click_on "Insert image"
      end

      within ".alchemy-dialog.modal" do
        # We expect to see both pictures
        expect(page).to have_selector("#overlay_picture_list a img", count: 2)

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

  describe "Upload button" do
    let(:options) do
      {grouped: true}
    end

    scenario 'passes options params to the uploader script' do
      visit alchemy.admin_pictures_path(element_id: element.id, options: options)

      expect(page.find('form#new_picture + script').text).to \
        match /#{Regexp.escape({options: options}.to_param)}/
    end
  end

  describe "assigning an image" do
    let!(:picture) { create(:alchemy_picture) }

    context 'when no content is present' do
      scenario 'it has link to create a content' do
        visit alchemy.admin_pictures_path(element_id: element.id)
        expect(page).to have_selector('a[data-method="post"][href*="/admin/contents"]')
      end
    end
  end
end
