# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::UploaderButton, type: :component do
  let(:object) { Alchemy::Picture.new }
  let(:file_attribute) { :image_file }
  let(:redirect_url) { "/admin/pictures" }

  subject(:render) do
    render_inline(described_class.new(object:, file_attribute:, redirect_url:))
  end

  it "renders a alchemy-uploader component" do
    render
    expect(page).to have_selector("alchemy-uploader[redirect-url='/admin/pictures']")
  end

  context "when wildcard is configured (all file types allowed)" do
    before do
      allow(Alchemy.config.uploader.allowed_filetypes).to receive(:alchemy_pictures) do
        ["*"]
      end
    end

    it "does not render the accept attribute" do
      render
      expect(page).to have_selector('input[type="file"].fileupload')
      expect(page).not_to have_selector('input[type="file"][accept]')
    end
  end

  context "when specific file types are configured" do
    before do
      allow(Alchemy.config.uploader.allowed_filetypes).to receive(:alchemy_pictures) do
        ["jpg", "png", "gif"]
      end
    end

    it "renders the accept attribute with the correct file extensions" do
      render
      expect(page).to have_selector('input[type="file"].fileupload')
      expect(page).to have_selector('input[type="file"][accept=".jpg, .png, .gif"]')
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
      render
      expect(page).to have_selector('input[type="file"].fileupload')
      expect(page).not_to have_selector('input[type="file"][accept]')
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
      render
      expect(page).to have_selector('input[type="file"].fileupload')
      expect(page).to have_selector('input[type="file"][accept=".pdf, .doc, .docx"]')
    end
  end

  describe "label" do
    context "by default" do
      it "renders an icon button wrapped in a tooltip" do
        render
        expect(page).to have_selector("sl-tooltip span.icon_button")
        expect(page).not_to have_selector("span.button.with_icon")
      end
    end

    context "when inline_label is true" do
      subject(:render) do
        render_inline(described_class.new(object:, file_attribute:, redirect_url:, inline_label: true))
      end

      it "renders the label inline next to the icon" do
        render
        expect(page).to have_selector("span.button.with_icon", text: "Upload images")
      end

      it "does not wrap the button in a tooltip" do
        render
        expect(page).not_to have_selector("sl-tooltip")
      end
    end

    context "with a custom label" do
      subject(:render) do
        render_inline(described_class.new(object:, file_attribute:, redirect_url:, label: "Add picture", inline_label: true))
      end

      it "renders the custom label" do
        render
        expect(page).to have_selector("span.button.with_icon", text: "Add picture")
      end
    end
  end

  describe "upload_hash field" do
    context "when the object responds to upload_hash" do
      it "renders a hidden upload_hash field" do
        render
        expect(page).to have_selector('input[type="hidden"][name="picture[upload_hash]"]', visible: :hidden)
      end
    end

    context "when the object does not respond to upload_hash" do
      let(:object) { Alchemy::Attachment.new }
      let(:file_attribute) { :file }

      it "does not render a upload_hash field" do
        render
        expect(page).not_to have_selector('input[name*="upload_hash"]', visible: :all)
      end
    end
  end
end
