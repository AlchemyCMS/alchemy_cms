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
      tom_select "PDF Document", from: "File Type"
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

  describe "Assigning an attachment", :js do
    let!(:attachment) { create(:alchemy_attachment, name: "Pee Dee Eff", file: fixture_file_upload("file.pdf")) }
    let(:element) { create(:alchemy_element, :with_ingredients, name: "download") }
    let(:assign_requests) { Queue.new }

    around do |example|
      subscriber = ActiveSupport::Notifications.subscribe("process_action.action_controller") do |*, payload|
        assign_requests << payload if payload[:action] == "assign"
      end
      example.run
      ActiveSupport::Notifications.unsubscribe(subscriber)
    end

    scenario "assigns the attachment to the ingredient" do
      visit alchemy.admin_elements_path(page_version_id: element.page_version_id)

      within "#element_#{element.id}" do
        find("a[href*='/admin/attachments']").click
      end
      within ".alchemy-dialog" do
        find("li", text: attachment.name).click
      end

      expect(page).to have_no_css(".alchemy-dialog")
      expect(page).to have_css("#element_#{element.id}.dirty .file_name", text: attachment.name)
      expect(page).to have_css("#element_#{element.id} .remove_file_link")
      expect(find("[id$='attachment_id']", visible: :hidden).value).to eq(attachment.id.to_s)
    end

    scenario "double clicking an attachment only assigns it once" do
      visit alchemy.admin_elements_path(page_version_id: element.page_version_id)

      within "#element_#{element.id}" do
        find("a[href*='/admin/attachments']").click
      end
      within ".alchemy-dialog" do
        find("li", text: attachment.name).double_click
      end

      expect(page).to have_no_css(".alchemy-dialog")
      expect(page).to have_css("#element_#{element.id}.dirty .file_name", text: attachment.name)
      expect(assign_requests.size).to eq(1)
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
