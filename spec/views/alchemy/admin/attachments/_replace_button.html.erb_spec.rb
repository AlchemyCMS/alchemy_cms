# frozen_string_literal: true

require "rails_helper"

describe "alchemy/admin/attachments/_replace_button.html.erb" do
  let(:object) { Alchemy::Attachment.new(id: 666) }
  let(:file_attribute) { :file }
  let(:redirect_url) { "/admin/attachments" }

  before do
    allow(view).to receive(:admin_attachments_path).and_return("/admin/attachments")
    view.extend Alchemy::BaseHelper
  end

  it "renders a alchemy-uploader component" do
    render partial: "alchemy/admin/attachments/replace_button",
      locals: {object: object, file_attribute: file_attribute, redirect_url: redirect_url}
    expect(rendered).to have_selector("alchemy-uploader#file_upload_attachment_666")
  end

  context "with allowed_filetypes configured as wildcard" do
    before do
      allow(Alchemy.config.uploader.allowed_filetypes).to receive(:alchemy_attachments) do
        ["*"]
      end
    end

    it "does not render the accept attribute" do
      render partial: "alchemy/admin/attachments/replace_button",
        locals: {object: object, file_attribute: file_attribute, redirect_url: redirect_url}

      expect(rendered).not_to have_selector('input[type="file"][accept]')
    end
  end

  context "with allowed_filetypes configured as specific file types" do
    before do
      allow(Alchemy.config.uploader.allowed_filetypes).to receive(:alchemy_attachments) do
        ["pdf", "doc", "docx"]
      end
    end

    it "renders the accept attribute with the correct file extensions" do
      render partial: "alchemy/admin/attachments/replace_button",
        locals: {object: object, file_attribute: file_attribute, redirect_url: redirect_url}

      expect(rendered).to have_selector('input[type="file"][accept=".pdf, .doc, .docx"]')
    end
  end
end
