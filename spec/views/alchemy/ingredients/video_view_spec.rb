# frozen_string_literal: true

require "rails_helper"

RSpec.describe "alchemy/ingredients/_video_view" do
  let(:file) do
    File.new(File.expand_path("../../../fixtures/image with spaces.png", __dir__))
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
      preload: "auto",
      width: 1280,
    )
  end

  context "without attachment" do
    let(:ingredient) { Alchemy::Ingredients::Video.new(attachment: nil) }

    it "renders nothing" do
      render ingredient
      expect(rendered).to eq("")
    end
  end

  context "with attachment" do
    it "renders a video tag with source" do
      render ingredient
      expect(rendered).to have_selector(
        "video[controls][muted][loop][autoplay][preload='auto'][width='1280'][height='720'] source[src]"
      )
    end
  end
end
