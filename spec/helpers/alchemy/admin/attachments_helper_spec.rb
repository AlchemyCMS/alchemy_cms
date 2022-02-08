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
end
