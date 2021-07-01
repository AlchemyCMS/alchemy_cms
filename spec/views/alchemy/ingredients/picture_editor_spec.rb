# frozen_string_literal: true

require "rails_helper"

RSpec.describe "alchemy/ingredients/_picture_editor" do
  let(:picture) { stub_model(Alchemy::Picture) }
  let(:element) { build_stubbed(:alchemy_element, name: "all_you_can_eat_ingredients") }
  let(:element_editor) { Alchemy::ElementEditor.new(element) }

  let(:ingredient) do
    stub_model(
      Alchemy::Ingredients::Picture,
      caption: "This is a cute cat",
      element: element,
      picture: picture,
      role: "image",
    )
  end

  let(:settings) { {} }

  it_behaves_like "an alchemy ingredient editor"

  before do
    allow(element_editor).to receive(:ingredients) { [Alchemy::IngredientEditor.new(ingredient)] }
    allow(ingredient).to receive(:settings) { settings }
  end

  subject do
    render element_editor
    rendered
  end

  context "with settings[:deletable] being nil" do
    it "should not render a button to link and unlink the picture" do
      is_expected.to have_selector("a .icon.fa-link")
      is_expected.to have_selector("a .icon.fa-unlink")
    end
  end

  context "with settings[:linkable] being false" do
    let(:settings) do
      {
        linkable: false,
      }
    end

    it "should not render a button to link and unlink the picture" do
      is_expected.to_not have_selector("a .icon.fa-link")
      is_expected.to_not have_selector("a .icon.fa-unlink")
    end

    it "but renders the disabled link and unlink icons" do
      is_expected.to have_selector(".icon.fa-link")
      is_expected.to have_selector(".icon.fa-unlink")
    end
  end

  context "with image cropping enabled" do
    before do
      allow(ingredient).to receive(:allow_image_cropping?) { true }
    end

    it "shows cropping link" do
      is_expected.to have_selector('a[href*="crop"]')
    end
  end

  context "with image cropping disabled" do
    before do
      allow(ingredient).to receive(:allow_image_cropping?) { false }
    end

    it "shows disabled cropping link" do
      is_expected.to have_selector("a.disabled .icon.fa-crop")
    end
  end
end
