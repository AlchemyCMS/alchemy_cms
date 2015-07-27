require 'spec_helper'

describe "essences/_essence_picture_editor" do
  let(:essence_picture) do
    stub_model(
      Alchemy::EssencePicture,
      picture: stub_model(Alchemy::Picture),
      caption: 'This is a cute cat'
    )
  end

  let(:content) do
    stub_model(
      Alchemy::Content,
      name: 'image',
      essence_type: 'EssencePicture',
      essence: essence_picture
    )
  end

  let(:options) { Hash.new }

  before do
    view.class.send(:include, Alchemy::BaseHelper)
    view.class.send(:include, Alchemy::EssencesHelper)
    allow(view).to receive(:content_label).and_return('')
    allow(view).to receive(:essence_picture_thumbnail).and_return('')
    allow(view).to receive(:link_to_dialog).and_return('')
    render partial: "alchemy/essences/essence_picture_editor",
      locals: {content: content, options: options}
  end

  context "with settings[:deletable] being nil" do
    it 'should not render a button to link and unlink the picture' do
      expect(rendered).to have_selector("a .icon.link")
      expect(rendered).to have_selector("a .icon.unlink")
    end
  end

  context "with settings[:deletable] being false" do
    let(:options) do
      {linkable: false}
    end

    it 'should not render a button to link and unlink the picture' do
      expect(rendered).to_not have_selector("a .icon.link")
      expect(rendered).to_not have_selector("a .icon.unlink")
    end

    it 'but renders the disabled link and unlink icons' do
      expect(rendered).to have_selector(".icon.link")
      expect(rendered).to have_selector(".icon.unlink")
    end
  end
end
