# frozen_string_literal: true

require "rails_helper"

describe "alchemy/admin/uploader/_button.html.erb" do
  let(:picture) { build_stubbed(:alchemy_picture) }
  let(:attachment) { build_stubbed(:alchemy_attachment) }

  before do
    allow(view).to receive(:render_icon).and_return("<svg>upload</svg>".html_safe)
  end

  describe "accept attribute handling with CollectionOption" do
    context "when file_types is a CollectionOption with wildcard ['*']" do
      before do
        # Ensure the config returns the actual CollectionOption object
        allow(Alchemy.config.uploader.allowed_filetypes).to receive(:[])
          .with("alchemy_attachments")
          .and_return(Alchemy.config.uploader.allowed_filetypes[:alchemy_attachments])
      end

      it "correctly compares CollectionOption.to_a with ['*'] and sets accept to false" do
        render partial: "alchemy/admin/uploader/button",
          locals: {
            object: attachment,
            file_attribute: :file,
            redirect_url: "/admin/attachments"
          }

        # When accept is false, the attribute should not be present
        expect(rendered).to have_selector('input[type="file"]:not([accept])')
      end
    end

    context "when file_types is a CollectionOption with specific image types" do
      before do
        # Return the actual CollectionOption for pictures
        allow(Alchemy.config.uploader.allowed_filetypes).to receive(:[])
          .with("alchemy_pictures")
          .and_return(Alchemy.config.uploader.allowed_filetypes[:alchemy_pictures])
      end

      it "correctly handles CollectionOption.to_a != ['*'] and sets accept attribute" do
        render partial: "alchemy/admin/uploader/button",
          locals: {
            object: picture,
            file_attribute: :image_file,
            redirect_url: "/admin/pictures"
          }

        # Should have accept attribute with specific file types
        expect(rendered).to have_selector('input[type="file"][accept]')
        expect(rendered).to have_selector('input[type="file"][accept*=".jpg"]')
        expect(rendered).to have_selector('input[type="file"][accept*=".png"]')
      end
    end

    context "when allowed_filetypes returns nil (fallback case)" do
      before do
        allow(Alchemy.config.uploader.allowed_filetypes).to receive(:[])
          .and_return(nil)
      end

      it "defaults to ['*'] and sets accept to false" do
        render partial: "alchemy/admin/uploader/button",
          locals: {
            object: picture,
            file_attribute: :image_file,
            redirect_url: "/admin/pictures"
          }

        # Should fallback to wildcard, so no accept attribute
        expect(rendered).to have_selector('input[type="file"]:not([accept])')
      end
    end
  end

  describe "regression test for CollectionOption comparison bug" do
    it "ensures CollectionOption objects are converted to arrays before comparison" do
      # This tests the specific fix: file_types.to_a == ["*"] instead of file_types == ["*"]
      file_types = Alchemy.config.uploader.allowed_filetypes[:alchemy_attachments]

      # The bug: CollectionOption == Array never matches
      expect(file_types == ["*"]).to eq(false), "CollectionOption should not equal Array directly"

      # The fix: Convert to array first
      expect(file_types.to_a == ["*"]).to eq(true), "CollectionOption.to_a should equal ['*']"
    end
  end
end
