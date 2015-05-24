require 'spec_helper'

RSpec.feature "Picture Library" do
  before do
    authorize_user(:as_admin)
  end

  describe "Tagging" do
    let!(:picture_1) { create(:picture, tag_list: 'tag1', name: 'TaggedWith1') }
    let!(:picture_2) { create(:picture, tag_list: 'tag2', name: 'TaggedWith2') }

    scenario "it's possible to filter tags by clicking on its name in the tag list." do
      visit alchemy.admin_pictures_path

      click_on 'tag1 (1)'

      expect(page).to have_content('TaggedWith1')
      expect(page).not_to have_content('TaggedWith2')
    end

    scenario "it's possible to undo tag filtering by clicking on an active tag name" do
      visit alchemy.admin_pictures_path

      click_on 'tag1 (1)'

      expect(page).to have_content('TaggedWith1')
      expect(page).not_to have_content('TaggedWith2')

      click_on 'tag1 (1)'

      expect(page).to have_content('TaggedWith1')
      expect(page).to have_content('TaggedWith2')
    end

    scenario "it's possible to tighten the tag scope by clicking on another tag name." do
      visit alchemy.admin_pictures_path

      click_on 'tag1 (1)'
      click_on 'tag2 (1)'

      expect(page).to have_content("You don't have any images in your archive")
    end
  end

  describe "Filter by tag" do
    let!(:picture) { create(:picture, tag_list: 'bla') }

    scenario "lists all applied tags." do
      visit alchemy.admin_pictures_path

      expect(page).to have_content('bla')
    end

    scenario "it's possible to filter pictures by tag." do
      visit alchemy.admin_pictures_path

      click_on 'bla (1)'

      expect(page).to have_content('bla')
    end
  end
end
