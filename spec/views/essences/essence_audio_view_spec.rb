# frozen_string_literal: true

require "rails_helper"

describe "alchemy/essences/_essence_audio_view" do
  let(:file) do
    File.new(File.expand_path("../../fixtures/image with spaces.png", __dir__))
  end

  let(:attachment) do
    build_stubbed(:alchemy_attachment, file: file, name: "a podcast", file_name: "image with spaces.png")
  end

  let(:essence) { Alchemy::EssenceAudio.new(attachment: attachment) }
  let(:content) { Alchemy::Content.new(essence: essence) }

  context "without attachment" do
    let(:essence) { Alchemy::EssenceAudio.new(attachment: nil) }

    it "renders nothing" do
      render content, content: content
      expect(rendered).to eq("")
    end
  end

  context "with attachment" do
    it "renders a audio tag with source" do
      render content, content: content
      expect(rendered).to have_selector(
        "audio[controls] source[src]"
      )
    end
  end
end
