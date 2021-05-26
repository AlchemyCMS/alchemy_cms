# frozen_string_literal: true

require "rails_helper"

RSpec.describe "alchemy/ingredients/_audio_view" do
  let(:file) do
    File.new(File.expand_path("../../../fixtures/image with spaces.png", __dir__))
  end

  let(:attachment) do
    build_stubbed(:alchemy_attachment, file: file, name: "a podcast", file_name: "image with spaces.png")
  end

  let(:ingredient) do
    Alchemy::Ingredients::Audio.new(
      role: "video",
      attachment: attachment,
      autoplay: true,
      controls: true,
      loop: true,
      muted: true,
    )
  end

  context "without attachment" do
    let(:ingredient) { Alchemy::Ingredients::Audio.new(attachment: nil) }

    it "renders nothing" do
      render ingredient
      expect(rendered).to eq("")
    end
  end

  context "with attachment" do
    it "renders a audio tag with source" do
      render ingredient
      expect(rendered).to have_selector(
        "audio[controls][muted][loop][autoplay] source[src]"
      )
    end
  end
end
