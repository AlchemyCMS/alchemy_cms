# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::PictureEditor, type: :component do
  let(:alchemy_page) { stub_model(Alchemy::Page) }
  let(:picture) { stub_model(Alchemy::Picture) }
  let(:element) { build_stubbed(:alchemy_element, name: "all_you_can_eat") }
  let(:ingredient_editor) { described_class.new(ingredient) }

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
    allow(ingredient).to receive(:settings) { settings }
    vc_test_view_context.class.include Alchemy::Admin::BaseHelper
    vc_test_view_context.instance_variable_set(:@page, alchemy_page)
  end

  subject do
    render_inline ingredient_editor
    page
  end

  it "should render a alchemy-picture-editor" do
    is_expected.to have_selector("alchemy-picture-editor")
  end

  it "should render a button to remove the picture" do
    is_expected.to have_selector('button.picture_tool.delete[type="button"]')
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

  context "with css_class present" do
    before do
      allow(ingredient).to receive(:css_class) { "left" }
    end

    it "renders the css class display" do
      is_expected.to have_selector(".picture_ingredient_css_class", text: "Left")
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

  context "with settings `only`" do
    let(:settings) { {only: "jpeg"} }

    it "renders a link to open the picture library overlay with only jpegs" do
      is_expected.to have_selector("a[href*='only%5B%5D=jpeg']")
    end
  end

  context "with settings `except`" do
    let(:settings) { {except: "gif"} }

    it "renders a link to open the picture library overlay without gifs" do
      is_expected.to have_selector("a[href*='except%5B%5D=gif']")
    end
  end

  describe "#ingredient_label" do
    context "with another column given" do
      it "has for attribute set to ingredient form field id for that column" do
        is_expected.to have_selector("label[for='element_#{element.id}_ingredient_#{ingredient.id}_picture_id']")
      end
    end
  end
end
