# frozen_string_literal: true

require "rails_helper"

describe "alchemy/essences/_essence_picture_editor" do
  let(:picture) { stub_model(Alchemy::Picture) }

  let(:essence_picture) do
    stub_model(
      Alchemy::EssencePicture,
      picture: picture,
      caption: "This is a cute cat",
    )
  end

  let(:content) do
    stub_model(
      Alchemy::Content,
      name: "image",
      essence_type: "EssencePicture",
      essence: essence_picture,
    )
  end

  let(:settings) { Hash.new }

  before do
    view.class.send(:include, Alchemy::Admin::BaseHelper)
    view.class.send(:include, Alchemy::Admin::EssencesHelper)
    allow(view).to receive(:content_label).and_return("")
    allow(view).to receive(:essence_picture_thumbnail).and_return("")
  end

  subject do
    allow(content).to receive(:settings) { settings }
    render partial: "alchemy/essences/essence_picture_editor",
      locals: {essence_picture_editor: Alchemy::ContentEditor.new(content)}
    rendered
  end

  context "with settings[:deletable] being nil" do
    it "should not render a button to link and unlink the picture" do
      is_expected.to have_selector("a .icon.fa-link")
      is_expected.to have_selector("a .icon.fa-unlink")
    end
  end

  context "with settings[:deletable] being false" do
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

  context "with allow_image_cropping? true" do
    before do
      allow(essence_picture).to receive(:allow_image_cropping?) { true }
    end

    it "shows cropping link" do
      is_expected.to have_selector('a[href*="crop"]')
    end
  end

  context "with allow_image_cropping? false" do
    before do
      allow(essence_picture).to receive(:allow_image_cropping?) { false }
    end

    it "shows disabled cropping link" do
      is_expected.to have_selector("a.disabled .icon.fa-crop")
    end
  end
end
