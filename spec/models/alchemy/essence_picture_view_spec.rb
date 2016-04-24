require 'spec_helper'

describe Alchemy::EssencePictureView, type: :model do
  include Capybara::RSpecMatchers

  let(:essence_picture) do
    stub_model Alchemy::EssencePicture,
      picture: stub_model(Alchemy::Picture, image_file_format: 'jpg'),
      caption: 'This is a cute cat'
  end

  let(:content) do
    stub_model Alchemy::Content,
      name: 'image',
      essence_type: 'EssencePicture',
      essence: essence_picture
  end

  context "with caption" do
    let(:options) do
      {}
    end

    let(:html_options) do
      {}
    end

    subject do
      Alchemy::EssencePictureView.new(content, options, html_options).render
    end

    it "should enclose the image in a <figure> element" do
      is_expected.to have_selector('figure img')
    end

    it "should shows the caption" do
      should have_selector('figure figcaption')
      should have_content('This is a cute cat')
    end

    context "but disabled in the options" do
      let(:options) do
        {show_caption: false}
      end

      it "should not enclose the image in a <figure> element" do
        should_not have_selector('figure img')
      end

      it "should not show the caption" do
        should_not have_selector('figure figcaption')
        should_not have_content('This is a cute cat')
      end
    end

    context "but disabled in the content settings" do
      before do
        allow(content).to receive(:settings).and_return({show_caption: false})
      end

      it "should not enclose the image in a <figure> element" do
        should_not have_selector('figure img')
      end

      it "should not show the caption" do
        should_not have_selector('figure figcaption')
        should_not have_content('This is a cute cat')
      end

      context 'but enabled in the options hash' do
        let(:options) { {show_caption: true} }

        it "should enclose the image in a <figure> element" do
          should have_selector('figure img')
        end

        it "should show the caption" do
          should have_selector('figure figcaption')
          should have_content('This is a cute cat')
        end
      end
    end

    context "and essence with css class" do
      before do
        essence_picture.css_class = 'left'
      end

      it "should have the class on the <figure> element" do
        is_expected.to have_selector('figure.left img')
      end

      it "should not have the class on the <img> element" do
        is_expected.not_to have_selector('figure img.left')
      end
    end

    context "and css class in the html_options" do
      before do
        html_options[:class] = 'right'
      end

      it "should have the class from the html_options on the <figure> element" do
        is_expected.to have_selector('figure.right img')
      end

      it "should not have the class from the essence on the <figure> element" do
        is_expected.not_to have_selector('figure.left img')
      end

      it "should not have the class from the html_options on the <img> element" do
        is_expected.not_to have_selector('figure img.right')
      end
    end
  end

  context "with link" do
    let(:options) do
      {}
    end

    subject do
      essence_picture.link = '/home'
      Alchemy::EssencePictureView.new(content, options).render
    end

    it "should enclose the image in a link tag" do
      is_expected.to have_selector('a[href="/home"] img')
    end

    context "but disabled link option" do
      before do
        options[:disable_link] = true
      end

      it "should not enclose the image in a link tag" do
        is_expected.not_to have_selector('a img')
      end
    end
  end
end
