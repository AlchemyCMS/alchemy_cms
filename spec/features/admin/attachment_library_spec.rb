# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Attachment Library", type: :system do
  before do
    authorize_user(:as_admin)
  end

  let!(:language) { create(:alchemy_language) }

  describe "Filter by format" do
    let!(:attachment1) do
      create(:alchemy_attachment, name: "Pee Dee Eff", file_name: "file.pdf", file_mime_type: "application/pdf")
    end

    let!(:attachment2) do
      create(:alchemy_attachment, name: "Zip File", file_name: "archive.zip", file_mime_type: "application/zip")
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
