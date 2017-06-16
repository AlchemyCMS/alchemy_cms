require 'spec_helper'

RSpec.feature "Attachment assignment overlay" do
  before do
    authorize_user(:as_admin)
  end

  describe "filter by tags", js: true do
    let(:a_page) { create(:alchemy_page, do_not_autogenerate: false) }
    let(:element) { create(:alchemy_element, page: a_page, name: 'download') }
    let!(:file1) { create(:alchemy_attachment, file_name: "job_alert.png", tag_list: "jobs") }
    let!(:file2) { create(:alchemy_attachment, file_name: "keynote.png", tag_list: "presentations") }

    scenario "shows only the attachments tagged with the selected tag" do
      visit alchemy.edit_admin_page_path(a_page)

      within "#element_area div[data-element-name='download'] .file_icon" do
        click_on "Assign a file"
      end

      within ".alchemy-dialog.modal" do
        # We expect to see both attachments
        expect(page).to have_selector("#assign_file_list .list a", count: 2)

        # Click on a tag to filter the attachments
        within ".tag-list" do
          click_on "jobs (1)"
        end

        # We expect to see only the attachment tagged with 'jobs'.
        expect(page).to have_selector("#assign_file_list .list a", count: 1)
        expect(page).to have_selector("#assign_file_list .list a span", text: "job alert")
      end
    end
  end
end
