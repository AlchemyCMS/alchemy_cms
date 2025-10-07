# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::PictureThumbnail, type: :component do
  let(:component) do
    described_class.new(picture)
  end

  let(:picture) { create(:alchemy_picture) }

  it "renders medium thumbnail" do
    expect(picture).to receive(:thumbnail_url).with(size: "160x120")
    render_inline component
  end

  context "with picture description for current language" do
    before do
      language = create(:alchemy_language)
      Alchemy::Current.language = language
      Alchemy::PictureDescription.create!(picture: picture, language: language, text: "Picture description")
    end

    it "adds description as name attribute" do
      render_inline component
      expect(page).to have_css("alchemy-picture-thumbnail[name='Picture description']")
    end
  end

  context "without picture description for current language" do
    it "adds picture name as name attribute" do
      render_inline component
      expect(page).to have_css("alchemy-picture-thumbnail[name='image']")
    end
  end

  context "when size is 'small'" do
    let(:component) do
      described_class.new(picture, size: "small")
    end

    it "renders small thumbnail" do
      expect(picture).to receive(:thumbnail_url).with(size: "80x60")
      render_inline component
    end
  end

  context "when size is 'large'" do
    let(:component) do
      described_class.new(picture, size: "large")
    end

    it "renders large thumbnail" do
      expect(picture).to receive(:thumbnail_url).with(size: "240x180")
      render_inline component
    end
  end

  context "when css_class is given" do
    let(:component) do
      described_class.new(picture, css_class: "padding-top")
    end

    it "adds class" do
      render_inline component
      expect(page).to have_css(".padding-top")
    end
  end

  context "when thumbnail_url is is nil" do
    before do
      allow(picture).to receive(:thumbnail_url) { nil }
    end

    it "renders file-damage icon" do
      render_inline component
      expect(page).to have_css("alchemy-icon[name=file-damage]")
    end

    context "when placeholder is given" do
      let(:component) do
        described_class.new(picture, placeholder: "<alchemy-icon name='image' size='xl'></alchemy-icon>".html_safe)
      end

      it "renders file-damage icon" do
        render_inline component

        expect(page).to have_css("alchemy-icon[name=image][size=xl]")
      end
    end
  end
end
