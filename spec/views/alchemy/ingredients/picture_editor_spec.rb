# frozen_string_literal: true

require "rails_helper"

RSpec.describe "alchemy/ingredients/_picture_editor" do
  let(:page) { stub_model(Alchemy::Page) }
  let(:picture) { stub_model(Alchemy::Picture) }
  let(:element) { build_stubbed(:alchemy_element, name: "all_you_can_eat") }
  let(:element_editor) { Alchemy::ElementEditor.new(element) }
  let(:ingredient_editor) { Alchemy::IngredientEditor.new(ingredient) }

  let(:ingredient) do
    stub_model(
      Alchemy::Ingredients::Picture,
      caption: "This is a cute cat",
      element: element,
      picture: picture,
      role: "image"
    )
  end

  let(:settings) { {} }

  it_behaves_like "an alchemy ingredient editor"

  before do
    allow(element_editor).to receive(:ingredients) { [ingredient_editor] }
    allow(ingredient).to receive(:settings) { settings }
    view.class.send :include, Alchemy::Admin::BaseHelper
    view.class.send :include, Alchemy::Admin::IngredientsHelper
    assign(:page, page)
  end

  subject do
    render element_editor
    rendered
  end

  context "with settings[:linkable] being nil" do
    it "should render a button to link and unlink the picture" do
      is_expected.to have_selector('button[is="alchemy-link-button"]')
      is_expected.to have_selector('button[is="alchemy-unlink-button"]')
    end
  end

  context "with settings[:linkable] being false" do
    let(:settings) do
      {
        linkable: false
      }
    end

    it "should not render a button to link and unlink the picture" do
      is_expected.to_not have_selector('button[is="alchemy-link-button"]')
      is_expected.to_not have_selector('button[is="alchemy-unlink-button"]')
    end

    it "but renders the disabled link and unlink icons" do
      is_expected.to have_selector('.disabled alchemy-icon[name="link"]')
      is_expected.to have_selector('.disabled alchemy-icon[name="link-unlink"]')
    end
  end

  context "with image cropping enabled" do
    before do
      allow(ingredient).to receive(:allow_image_cropping?) { true }
    end

    it "shows cropping link" do
      is_expected.to have_selector('a[href*="crop"]')
    end

    it "has crop_from hidden field" do
      is_expected.to have_selector("input[type=\"hidden\"][id=\"#{ingredient_editor.form_field_id(:crop_from)}\"]")
    end

    it "has crop_size hidden field" do
      is_expected.to have_selector("input[type=\"hidden\"][id=\"#{ingredient_editor.form_field_id(:crop_size)}\"]")
    end
  end

  context "with image cropping disabled" do
    before do
      allow(ingredient).to receive(:allow_image_cropping?) { false }
    end

    it "shows disabled cropping link" do
      is_expected.to have_selector('a.disabled alchemy-icon[name="crop"]')
    end
  end

  it "does not add a for attribute to the label tag" do
    is_expected.to have_selector("label", text: "Image")
    is_expected.to_not have_selector("label[for]", text: "Image")
  end
end
