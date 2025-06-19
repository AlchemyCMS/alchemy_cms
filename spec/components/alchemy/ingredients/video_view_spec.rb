# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::VideoView, type: :component do
  let(:file) do
    fixture_file_upload("image with spaces.png")
  end

  let(:attachment) do
    build_stubbed(:alchemy_attachment, file: file, name: "a movie", file_name: "image with spaces.png")
  end

  let(:ingredient) do
    Alchemy::Ingredients::Video.new(
      role: "video",
      attachment: attachment,
      allow_fullscreen: true,
      autoplay: true,
      controls: true,
      height: 720,
      loop: true,
      muted: true,
      playsinline: true,
      preload: "auto",
      width: 1280
    )
  end

  context "without attachment" do
    let(:ingredient) { Alchemy::Ingredients::Video.new(attachment: nil) }

    it "renders nothing" do
      render_inline described_class.new(ingredient)
      expect(page).to have_content("")
    end
  end

  context "with attachment" do
    it "renders a video tag with source" do
      render_inline described_class.new(ingredient)
      expect(page).to have_selector(
        "video[controls][muted][playsinline][loop][autoplay][preload='auto'][width='1280'][height='720'] source[src]"
      )
    end
  end

  context "with html_options" do
    it "adds them to the video tag" do
      render_inline described_class.new(ingredient, html_options: {preload: "metadata"})
      expect(page).to have_selector(
        "video[preload='metadata']"
      )
    end
  end
end
