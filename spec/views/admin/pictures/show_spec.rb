# frozen_string_literal: true

require "rails_helper"

describe "alchemy/admin/pictures/show.html.erb" do
  let(:image) do
    fixture_file_upload("animated.gif")
  end

  let(:picture) do
    create(:alchemy_picture, {
      image_file: image,
      name: "animated",
      image_file_name: "animated.gif"
    })
  end

  let(:language) { create(:alchemy_language) }

  let(:picture_description) do
    Alchemy::PictureDescription.create!(
      picture: picture,
      language: language,
      text: "This is an amazing image."
    )
  end

  before do
    allow(view).to receive(:admin_picture_path).and_return("/path")
    allow(view).to receive(:edit_admin_page_path).and_return("/path")
    allow(view).to receive(:render_message)
    allow(view).to receive(:description_field_name_prefix) { "prefix" }
    allow(view).to receive(:search_filter_params) { {} }
    view.extend Alchemy::Admin::FormHelper
    view.extend Alchemy::BaseHelper
    assign(:picture, picture)
    assign(:picture_description, picture_description)
  end

  it "displays picture in original format" do
    assign(:assignments, [])

    render

    expect(rendered).to have_selector('img[src*="gif"]')
  end

  it "separates the tags with a comma" do
    allow(picture).to receive(:tag_list).and_return(["one", "two", "three"])
    assign(:assignments, [])

    render

    expect(rendered).to have_selector('input[value*="one,two,three"]')
  end

  context "if picture is used" do
    let!(:picture_ingredient) { create(:alchemy_ingredient_picture, picture: picture) }

    it "displays a list of ingredients using the picture" do
      assign(:assignments, picture.related_ingredients.joins(element: :page))

      render

      expect(rendered).to have_css(".resource_page_list li a", text: picture_ingredient.element.page.name)
      expect(rendered).to have_content picture_ingredient.translated_role
    end
  end
end
