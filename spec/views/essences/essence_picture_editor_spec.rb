require 'spec_helper'

describe "essences/_essence_picture_editor" do
  let(:essence_picture) do
    create :essence_picture
  end

  let(:content) do
    create(:content, name: 'image', essence_type: 'EssencePicture', essence: essence_picture)
  end

  let(:options) { Hash.new }

  before do
    view.class.send(:include, Alchemy::BaseHelper)
    view.class.send(:include, Alchemy::EssencesHelper)
    view.class.send(:include, Alchemy::Admin::PictureStylesHelper)
    allow(view).to receive(:content_label).and_return('')
    allow(view).to receive(:essence_picture_thumbnail).and_return('')
  end

  subject do
    render partial: "alchemy/essences/essence_picture_editor",
      locals: {content: content, options: options}
    rendered
  end

  context "with settings[:deletable] being nil" do
    it 'should not render a button to link and unlink the picture' do
      is_expected.to have_selector("a .icon.link")
      is_expected.to have_selector("a .icon.unlink")
    end
  end

  context "with settings[:deletable] being false" do
    let(:options) do
      {linkable: false}
    end

    it 'should not render a button to link and unlink the picture' do
      is_expected.to_not have_selector("a .icon.link")
      is_expected.to_not have_selector("a .icon.unlink")
    end

    it 'but renders the disabled link and unlink icons' do
      is_expected.to have_selector(".icon.link")
      is_expected.to have_selector(".icon.unlink")
    end
  end

  context 'with allow_image_cropping? true' do
    before do
      allow(essence_picture).to receive(:allow_image_cropping?) { true }
    end

    it 'shows cropping (editing) link' do
      is_expected.to have_selector('a[href*="edit"]')
    end
  end

  context 'with allow_image_cropping? false' do
    before do
      allow(essence_picture).to receive(:allow_image_cropping?) { false }
    end

    it 'shows disabled cropping link' do
      is_expected.to have_selector('a.disabled .icon.crop')
    end
  end
end
