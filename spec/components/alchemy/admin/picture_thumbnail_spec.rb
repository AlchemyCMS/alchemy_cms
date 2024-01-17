# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::PictureThumbnail, type: :component do
  subject(:render) do
    render_inline described_class.new(picture)
  end

  let(:picture) { build(:alchemy_picture) }

  it "should render alchemy-picture-thumbnail custom element with image tag nested inside" do
    render
    expect(page).to have_selector("alchemy-picture-thumbnail img")
  end

  context "with a size param" do
    subject(:render) do
      render_inline described_class.new(picture, size: :small)
    end

    it "should renders a small image" do
      expect(picture).to receive(:thumbnail_url).with(size: "80x60").and_call_original
      render
    end
  end
end
