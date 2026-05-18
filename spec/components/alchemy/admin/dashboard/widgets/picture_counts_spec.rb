# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::Dashboard::Widgets::PictureCounts, type: :component do
  subject(:rendered) do
    render_inline(described_class.new)
    page
  end

  context "without any pictures" do
    it "renders zero count" do
      expect(rendered).to have_css(".widget-body")
      expect(rendered).to have_css(".count", text: "0")
    end
  end

  context "with pictures" do
    before do
      create_list(:alchemy_picture, 2)
    end

    it "renders the total count of pictures" do
      expect(rendered).to have_css(".count", text: "2")
    end

    it "renders the total file size of all pictures" do
      total_size = Alchemy::Picture.all.sum(&:image_file_size)
      expect(rendered).to have_css(".infos", text: ActiveSupport::NumberHelper.number_to_human_size(total_size))
    end
  end

  it "renders the title" do
    expect(rendered).to have_text(Alchemy::Picture.model_name.human(count: :many))
  end

  it "renders the icon" do
    expect(rendered).to have_css('alchemy-icon[name="multi-image"]')
  end

  it "renders a link to the pictures admin" do
    expect(rendered).to have_link(href: Alchemy::Engine.routes.url_helpers.admin_pictures_path)
  end
end
