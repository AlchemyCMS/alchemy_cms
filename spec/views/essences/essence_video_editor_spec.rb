# frozen_string_literal: true

require "rails_helper"

describe "alchemy/essences/_essence_video_editor" do
  let(:attachment) { build_stubbed(:alchemy_attachment) }
  let(:essence) { build_stubbed(:alchemy_essence_video, attachment: attachment) }
  let(:content) { build_stubbed(:alchemy_content, essence: essence) }

  subject do
    render partial: "alchemy/essences/essence_video_editor", locals: {
      essence_video_editor: Alchemy::ContentEditor.new(content),
    }
    rendered
  end

  before do
    view.class.send :include, Alchemy::Admin::BaseHelper
    allow(view).to receive(:content_label).and_return("")
  end

  context "with ingredient present" do
    before do
      allow(content).to receive(:ingredient).and_return(attachment)
    end

    it "renders a hidden field with attachment id" do
      is_expected.to have_selector("input[type='hidden'][value='#{attachment.id}']")
    end

    it "renders a link to open the attachment library overlay" do
      within ".essence_video_tools" do
        is_expected.to have_selector("a[href='/admin/attachments?content_id=#{content.id}']")
      end
    end

    it "renders a link to edit the essence" do
      within ".essence_video_tools" do
        is_expected.to have_selector("a[href='/admin/essence_videos/#{essence.id}/edit']")
      end
    end

    context "with content settings `only`" do
      it "renders a link to open the attachment library overlay with only pdfs" do
        within ".essence_video_tools" do
          expect(content).to receive(:settings).at_least(:once).and_return({ only: "pdf" })
          is_expected.to have_selector("a[href='/admin/attachments?content_id=#{content.id}&only=pdf']")
        end
      end
    end

    context "with content settings `except`" do
      it "renders a link to open the attachment library overlay without pdfs" do
        within ".essence_video_tools" do
          expect(content).to receive(:settings).at_least(:once).and_return({ except: "pdf" })
          is_expected.to have_selector("a[href='/admin/attachments?content_id=#{content.id}&except=pdf']")
        end
      end
    end
  end

  context "without ingredient present" do
    before do
      allow(content).to receive(:ingredient).and_return(nil)
    end

    it "renders a hidden field for attachment_id" do
      is_expected.to have_selector("input[type='hidden'][name='contents[#{content.id}][attachment_id]']")
    end
  end
end
