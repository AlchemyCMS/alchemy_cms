require 'spec_helper'

describe "essences/_essence_picture_view" do

  let(:essence_picture) { stub_model(Alchemy::EssencePicture, picture: stub_model(Alchemy::Picture), caption: 'This is a cute cat') }
  let(:content) { stub_model(Alchemy::Content, name: 'image', essence_type: 'EssencePicture', essence: essence_picture) }

  before do
    ActionView::Base.send(:include, Alchemy::UrlHelper)
    ActionView::Base.send(:include, Alchemy::EssencesHelper)
    view.stub(:configuration).and_return(:jpg)
  end

  context "with caption" do
    let(:options) { {show_caption: true} }
    let(:html_options) { {} }

    subject do
      render partial: "alchemy/essences/essence_picture_view", locals: {
        content: content,
        options: options,
        html_options: html_options
      }
    end

    it "should enclose the image in a <figure> element" do
      should have_selector('figure img')
    end

    context "and essence with css class" do
      before { essence_picture.css_class = 'left' }

      it "should have the class on the <figure> element" do
        should have_selector('figure.left img')
      end

      it "should not have the class on the <img> element" do
        should_not have_selector('figure img.left')
      end
    end

    context "and css class in the html_options" do
      before { html_options[:class] = 'right' }

      it "should have the class from the html_options on the <figure> element" do
        should have_selector('figure.right img')
      end

      it "should not have the class from the essence on the <figure> element" do
        should_not have_selector('figure.left img')
      end

      it "should not have the class from the html_options on the <img> element" do
        should_not have_selector('figure img.right')
      end
    end
  end

  context "with link" do
    let(:options) { {} }

    subject do
      essence_picture.link = '/home'
      render partial: "alchemy/essences/essence_picture_view", locals: {
        content: content,
        options: options,
        html_options: {}
      }
    end

    it "should enclose the image in a link tag" do
      should have_selector('a[href="/home"] img')
    end

    context "but disabled link option" do
      before { options[:disable_link] = true }

      it "should not enclose the image in a link tag" do
        should_not have_selector('a img')
      end
    end
  end

end
