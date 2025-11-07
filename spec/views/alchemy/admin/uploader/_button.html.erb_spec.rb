# frozen_string_literal: true

require "rails_helper"

describe "alchemy/admin/uploader/_button.html.erb" do
  let(:object) { Alchemy::Picture.new }
  let(:file_attribute) { :image_file }
  let(:redirect_url) { "/admin/pictures" }

  before do
    allow(view).to receive(:can?).and_return(true)
    allow(view).to receive(:admin_pictures_path).and_return("/admin/pictures")
    allow(view).to receive(:admin_attachments_path).and_return("/admin/attachments")
    view.extend Alchemy::BaseHelper
  end

  context "when wildcard is configured (all file types allowed)" do
    before do
      allow(Alchemy.config.uploader.allowed_filetypes).to receive(:alchemy_pictures) do
        ["*"]
      end
    end

    it "does not render the accept attribute" do
      render partial: "alchemy/admin/uploader/button",
        locals: {object: object, file_attribute: file_attribute, redirect_url: redirect_url}

      expect(rendered).to have_selector('input[type="file"].fileupload')
      expect(rendered).not_to have_selector('input[type="file"][accept]')
    end
  end

  context "when specific file types are configured" do
    before do
      allow(Alchemy.config.uploader.allowed_filetypes).to receive(:alchemy_pictures) do
        ["jpg", "png", "gif"]
      end
    end

    it "renders the accept attribute with the correct file extensions" do
      render partial: "alchemy/admin/uploader/button",
        locals: {object: object, file_attribute: file_attribute, redirect_url: redirect_url}

      expect(rendered).to have_selector('input[type="file"].fileupload')
      expect(rendered).to have_selector('input[type="file"][accept=".jpg, .png, .gif"]')
    end
  end

  context "with Attachment object and wildcard" do
    let(:object) { Alchemy::Attachment.new }
    let(:file_attribute) { :file }

    before do
      allow(Alchemy.config.uploader.allowed_filetypes).to receive(:alchemy_attachments) do
        ["*"]
      end
    end

    it "does not render the accept attribute" do
      render partial: "alchemy/admin/uploader/button",
        locals: {object: object, file_attribute: file_attribute, redirect_url: redirect_url}

      expect(rendered).to have_selector('input[type="file"].fileupload')
      expect(rendered).not_to have_selector('input[type="file"][accept]')
    end
  end

  context "with Attachment object and specific file types" do
    let(:object) { Alchemy::Attachment.new }
    let(:file_attribute) { :file }

    before do
      allow(Alchemy.config.uploader.allowed_filetypes).to receive(:alchemy_attachments) do
        ["pdf", "doc", "docx"]
      end
    end

    it "renders the accept attribute with the correct file extensions" do
      render partial: "alchemy/admin/uploader/button",
        locals: {object: object, file_attribute: file_attribute, redirect_url: redirect_url}

      expect(rendered).to have_selector('input[type="file"].fileupload')
      expect(rendered).to have_selector('input[type="file"][accept=".pdf, .doc, .docx"]')
    end
  end
end
