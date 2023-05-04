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

  it "renders Alchemy::PictureView" do
    expect_any_instance_of(Alchemy::Ingredients::PictureView).to receive(:call)
    render ingredient
  end
end
