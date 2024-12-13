# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Attachment Library", type: :system do
  before do
    authorize_user(:as_admin)
  end

  let!(:language) { create(:alchemy_language) }

  describe "Filter by format" do
    let!(:attachment1) do
      create(:alchemy_attachment, name: "Pee Dee Eff", file: fixture_file_upload("file.pdf"))
    end

    let!(:attachment2) do
      create(:alchemy_attachment, name: "Zip File", file: fixture_file_upload("archive.zip"))
    end

    scenario "it's possible to filter attachments by type.", :js do
      visit alchemy.admin_attachments_path
      select2 "PDF Document", from: "File Type"
      within "#archive_all" do
        expect(page).to have_content("file")
        expect(page).to_not have_content("archive")
      end
    end
  end
end
