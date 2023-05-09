# frozen_string_literal: true

require "rails_helper"

RSpec.describe "alchemy/ingredients/_picture_view" do
  let(:picture) { stub_model(Alchemy::Picture) }
  let(:element) { build(:alchemy_element) }

  let(:ingredient) do
    stub_model(
      Alchemy::Ingredients::Picture,
      caption: "This is a cute cat",
      element: element,
      picture: picture,
      role: "image"
    )
  end

  let(:options) do
    {
      disable_link: true,
      show_caption: false,
      size: "100x100"
    }
  end

  it "renders Alchemy::PictureView" do
    expect(Alchemy::Ingredients::PictureView).to receive(:new).with(
      ingredient,
      disable_link: true,
      html_options: {
        class: "my-picture"
      },
      picture_options: {
        size: "100x100"
      },
      show_caption: false,
      sizes: nil,
      srcset: nil
    ).and_call_original
    render ingredient, options: options, html_options: {class: "my-picture"}
  end
end
