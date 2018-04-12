# frozen_string_literal: true

require 'spec_helper'

describe Alchemy::EssencePictureView, type: :model do
  include Capybara::RSpecMatchers

  let(:image) do
    File.new(File.expand_path('../../fixtures/image.png', __dir__))
  end

  let(:picture) do
    stub_model Alchemy::Picture,
      image_file_format: 'png',
      image_file: image
  end

  let(:essence_picture) do
    stub_model Alchemy::EssencePicture,
      picture: picture,
      caption: 'This is a cute cat'
  end

  let(:content) do
    stub_model Alchemy::Content,
      name: 'image',
      essence_type: 'EssencePicture',
      essence: essence_picture
  end

  let(:picture_url) { '/pictures/1/image.png' }

  before do
    allow(picture).to receive(:url) { picture_url }
  end

  describe 'DEFAULT_OPTIONS' do
    it do
      expect(Alchemy::EssencePictureView::DEFAULT_OPTIONS).
        to be_a(HashWithIndifferentAccess)
    end
  end

  context "with caption" do
    let(:options) do
      {}
    end

    let(:html_options) do
      {}
    end

    subject(:view) do
      Alchemy::EssencePictureView.new(content, options, html_options).render
    end

    it "should enclose the image in a <figure> element" do
      expect(view).to have_selector('figure img')
    end

    it "should show the caption" do
      expect(view).to have_selector('figure figcaption')
      expect(view).to have_content('This is a cute cat')
    end

    it "does not pass default options to picture url" do
      expect(essence_picture).to receive(:picture_url).with({}) { picture_url }
      view
    end

    context "but disabled in the options" do
      let(:options) do
        {show_caption: false}
      end

      it "should not enclose the image in a <figure> element" do
        expect(view).to_not have_selector('figure img')
      end

      it "should not show the caption" do
        expect(view).to_not have_selector('figure figcaption')
        expect(view).to_not have_content('This is a cute cat')
      end
    end

    context "but disabled in the content settings" do
      before do
        allow(content).to receive(:settings).and_return({show_caption: false})
      end

      it "should not enclose the image in a <figure> element" do
        expect(view).to_not have_selector('figure img')
      end

      it "should not show the caption" do
        expect(view).to_not have_selector('figure figcaption')
        expect(view).to_not have_content('This is a cute cat')
      end

      context 'but enabled in the options hash' do
        let(:options) { {show_caption: true} }

        it "should enclose the image in a <figure> element" do
          expect(view).to have_selector('figure img')
        end

        it "should show the caption" do
          expect(view).to have_selector('figure figcaption')
          expect(view).to have_content('This is a cute cat')
        end
      end
    end

    context "and essence with css class" do
      before do
        essence_picture.css_class = 'left'
      end

      it "should have the class on the <figure> element" do
        expect(view).to have_selector('figure.left img')
      end

      it "should not have the class on the <img> element" do
        expect(view).not_to have_selector('figure img.left')
      end
    end

    context "and css class in the html_options" do
      before do
        html_options[:class] = 'right'
      end

      it "should have the class from the html_options on the <figure> element" do
        expect(view).to have_selector('figure.right img')
      end

      it "should not have the class from the essence on the <figure> element" do
        expect(view).not_to have_selector('figure.left img')
      end

      it "should not have the class from the html_options on the <img> element" do
        expect(view).not_to have_selector('figure img.right')
      end
    end
  end

  context "with link" do
    let(:options) do
      {}
    end

    subject(:view) do
      essence_picture.link = '/home'
      Alchemy::EssencePictureView.new(content, options).render
    end

    it "should enclose the image in a link tag" do
      expect(view).to have_selector('a[href="/home"] img')
    end

    context "but disabled link option" do
      before do
        options[:disable_link] = true
      end

      it "should not enclose the image in a link tag" do
        expect(view).not_to have_selector('a img')
      end
    end
  end

  context "with multiple instances" do
    let(:options) do
      {}
    end

    subject(:picture_view) do
      Alchemy::EssencePictureView.new(content, options)
    end

    it "does not overwrite DEFAULT_OPTIONS" do
      Alchemy::EssencePictureView.new(content, {my_custom_option: true})
      expect(picture_view.options).to_not have_key(:my_custom_option)
    end
  end

  context "with srcset content setting" do
    before do
      allow(content).to receive(:settings) do
        {srcset: srcset}
      end
    end

    subject(:view) do
      Alchemy::EssencePictureView.new(content).render
    end

    let(:srcset) do
      []
    end

    it 'does not pass srcset option to picture_url' do
      expect(essence_picture).to receive(:picture_url).with({}) { picture_url }
      view
    end

    context "when only width or width and height are set" do
      let(:srcset) do
        %w(1024x768 800x)
      end

      it 'adds srcset attribute including image url and width for each size' do
        url1 = essence_picture.picture_url(size: '1024x768')
        url2 = essence_picture.picture_url(size: '800x')

        expect(view).to have_selector("img[srcset=\"#{url1} 1024w, #{url2} 800w\"]")
      end
    end

    context "when only height is set" do
      let(:srcset) do
        %w(x768 x600)
      end

      it 'adds srcset attribute including image url and height for each size' do
        url1 = essence_picture.picture_url(size: 'x768')
        url2 = essence_picture.picture_url(size: 'x600')

        expect(view).to have_selector("img[srcset=\"#{url1} 768h, #{url2} 600h\"]")
      end
    end
  end

  context "with no srcset content setting" do
    subject(:view) do
      Alchemy::EssencePictureView.new(content).render
    end

    it 'image tag has no srcset attribute' do
      expect(view).not_to have_selector('img[srcset]')
    end
  end

  context "with sizes content setting" do
    before do
      allow(content).to receive(:settings) do
        {sizes: sizes}
      end
    end

    subject(:view) do
      Alchemy::EssencePictureView.new(content).render
    end

    let(:sizes) do
      [
        '(max-width: 1023px) 100vh',
        '(min-width: 1024px) 33.333vh'
      ]
    end

    it 'does not pass sizes option to picture_url' do
      expect(essence_picture).to receive(:picture_url).with({}) { picture_url }
      view
    end

    it 'adds sizes attribute for each size' do
      expect(view).to have_selector("img[sizes=\"#{sizes[0]}, #{sizes[1]}\"]")
    end
  end

  context "with no sizes content setting" do
    subject(:view) do
      Alchemy::EssencePictureView.new(content).render
    end

    it 'image tag has no sizes attribute' do
      expect(view).not_to have_selector('img[sizes]')
    end
  end
end
