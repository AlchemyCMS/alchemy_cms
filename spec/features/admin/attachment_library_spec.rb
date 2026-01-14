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

    scenario "the list of file types can be constraint by passing the `only` param" do
      visit alchemy.admin_attachments_path(only: ["zip"])

      within "#library_sidebar" do
        expect(page).to have_css("option", text: "ZIP Archive")
        expect(page).to_not have_css("option", text: "PDF Document")
      end
    end

    scenario "the list of file types can be constraint by passing the `except` param" do
      visit alchemy.admin_attachments_path(except: ["zip"])

      within "#library_sidebar" do
        expect(page).to_not have_css("option", text: "ZIP Archive")
        expect(page).to have_css("option", text: "PDF Document")
      end
    end
  end

  describe "Sorting attachments", :js do
    let!(:attachment_a) { create(:alchemy_attachment, name: "A File", created_at: 2.days.ago) }
    let!(:attachment_b) { create(:alchemy_attachment, name: "B File", created_at: 1.day.ago) }

    scenario "it sorts attachments by latest by default." do
      visit alchemy.admin_attachments_path

      within "table.list" do
        expect(page).to have_css("tr:nth-child(1) td.name", text: "B File")
        expect(page).to have_css("tr:nth-child(2) td.name", text: "A File")
      end
    end

    scenario "it's possible to sort attachments by name." do
      visit alchemy.admin_attachments_path

      select "A-Z", from: "Sorting"
      within "table.list" do
        expect(page).to have_css("tr:nth-child(1) td.name", text: "A File")
        expect(page).to have_css("tr:nth-child(2) td.name", text: "B File")
      end
    end
  end

  describe "Sorting attachments", :js do
    let!(:attachment_a) { create(:alchemy_attachment, name: "A File", created_at: 2.days.ago) }
    let!(:attachment_b) { create(:alchemy_attachment, name: "B File", created_at: 1.day.ago) }

    scenario "it sorts attachments by latest by default." do
      visit alchemy.admin_attachments_path

      within "table.list" do
        expect(page).to have_css("tr:nth-child(1) td.name", text: "B File")
        expect(page).to have_css("tr:nth-child(2) td.name", text: "A File")
      end
    end

    scenario "it's possible to sort attachments by name." do
      visit alchemy.admin_attachments_path

      select "A-Z", from: "Sorting"
      within "table.list" do
        expect(page).to have_css("tr:nth-child(1) td.name", text: "A File")
        expect(page).to have_css("tr:nth-child(2) td.name", text: "B File")
      end
    end
  end
end
