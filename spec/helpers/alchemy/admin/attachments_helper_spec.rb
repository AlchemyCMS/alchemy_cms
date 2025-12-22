# frozen_string_literal: true

require "rails_helper"

describe Alchemy::Admin::AttachmentsHelper do
  describe "#mime_to_human" do
    context "when given mime type has no translation" do
      it "should return the default" do
        expect(helper.mime_to_human("something")).to eq("File")
      end
    end

    it "should return the translation for the given mime type" do
      expect(helper.mime_to_human("text/plain")).to eq("Plain Text Document")
    end
  end

  describe "#attachment_preview_size" do
    subject { helper.attachment_preview_size(attachment) }

    let(:attachment) { instance_double("Alchemy::Attachment") }

    before do
      allow(attachment).to receive(:file_mime_type) { mime_type }
    end

    context "for an audio attachment" do
      let(:mime_type) { "audio/mpeg" }

      it { is_expected.to eq("850x190") }
    end

    context "for an image attachment" do
      let(:mime_type) { "image/png" }

      it { is_expected.to eq("850x280") }
    end

    context "for an pdf attachment" do
      let(:mime_type) { "application/pdf" }

      it { is_expected.to eq("850x600") }
    end

    context "for an video attachment" do
      let(:mime_type) { "video/mp4" }

      it { is_expected.to eq("850x240") }
    end

    context "for any other file" do
      let(:mime_type) { "foo/bar" }

      it { is_expected.to eq("500x165") }
    end
  end
end
