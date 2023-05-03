# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::PictureView, type: :component do
  let(:image) do
    File.new(File.expand_path("../../fixtures/image.png", __dir__))
  end

  let(:picture) do
    stub_model Alchemy::Picture,
      image_file_format: "png",
      image_file: image
  end

  let(:ingredient) do
    stub_model Alchemy::Ingredients::Picture,
      role: "image",
      picture: picture,
      data: {
        caption: "This is a cute cat"
      }
  end

  let(:picture_url) { "/pictures/1/image.png" }

  before do
    allow(picture).to receive(:url) { picture_url }
  end

  describe "DEFAULT_OPTIONS" do
    subject { Alchemy::PictureView::DEFAULT_OPTIONS }

    it do
      is_expected.to eq({
        show_caption: true,
        disable_link: false,
        srcset: [],
        sizes: []
      }.with_indifferent_access)
    end
  end

  context "with caption" do
    let(:options) do
      {}
    end

    let(:html_options) do
      {}
    end

    subject(:render_view) do
      render_inline described_class.new(ingredient, options: options, html_options: html_options)
    end

    it "should enclose the image in a <figure> element" do
      render_view
      expect(page).to have_selector("figure img")
    end

    it "should show the caption" do
      render_view
      expect(page).to have_selector("figure figcaption")
      expect(page).to have_content("This is a cute cat")
    end

    it "does not pass default options to picture url" do
      expect(ingredient).to receive(:picture_url).with({}) { picture_url }
      render_view
    end

    context "but disabled in the options" do
      let(:options) do
        {show_caption: false}
      end

      it "should not enclose the image in a <figure> element" do
        render_view
        expect(page).to_not have_selector("figure img")
      end

      it "should not show the caption" do
        render_view
        expect(page).to_not have_selector("figure figcaption")
        expect(page).to_not have_content("This is a cute cat")
      end
    end

    context "but disabled in the ingredient settings" do
      before do
        allow(ingredient).to receive(:settings).and_return({show_caption: false})
        render_view
      end

      it "should not enclose the image in a <figure> element" do
        expect(page).to_not have_selector("figure img")
      end

      it "should not show the caption" do
        expect(page).to_not have_selector("figure figcaption")
        expect(page).to_not have_content("This is a cute cat")
      end

      context "but enabled in the options hash" do
        let(:options) { {show_caption: true} }

        it "should enclose the image in a <figure> element" do
          expect(page).to have_selector("figure img")
        end

        it "should show the caption" do
          expect(page).to have_selector("figure figcaption")
          expect(page).to have_content("This is a cute cat")
        end
      end
    end

    context "and ingredient with css class" do
      before do
        ingredient.css_class = "left"
        render_view
      end

      it "should have the class on the <figure> element" do
        expect(page).to have_selector("figure.left img")
      end

      it "should not have the class on the <img> element" do
        expect(page).not_to have_selector("figure img.left")
      end
    end

    context "and css class in the html_options" do
      before do
        html_options[:class] = "right"
        render_view
      end

      it "should have the class from the html_options on the <figure> element" do
        expect(page).to have_selector("figure.right img")
      end

      it "should not have the class from the ingredient on the <figure> element" do
        expect(page).not_to have_selector("figure.left img")
      end

      it "should not have the class from the html_options on the <img> element" do
        expect(page).not_to have_selector("figure img.right")
      end
    end
  end

  context "with link" do
    let(:options) do
      {}
    end

    subject(:render_view) do
      ingredient.link = "/home"
      render_inline described_class.new(ingredient, options: options)
    end

    it "should enclose the image in a link tag" do
      render_view
      expect(page).to have_selector('a[href="/home"] img')
    end

    context "but disabled link option" do
      before do
        options[:disable_link] = true
        render_view
      end

      it "should not enclose the image in a link tag" do
        expect(page).not_to have_selector("a img")
      end
    end
  end

  context "with multiple instances" do
    let(:options) do
      {}
    end

    subject(:picture_view) do
      described_class.new(ingredient, options: options)
    end

    it "does not overwrite DEFAULT_OPTIONS" do
      described_class.new(ingredient, options: {my_custom_option: true})
      expect(picture_view.options).to_not have_key(:my_custom_option)
    end
  end

  context "with srcset ingredient setting" do
    before do
      allow(ingredient).to receive(:settings) do
        {srcset: srcset}
      end
    end

    subject(:render_view) do
      render_inline described_class.new(ingredient)
    end

    let(:srcset) do
      []
    end

    it "does not pass srcset option to picture_url" do
      expect(ingredient).to receive(:picture_url).with({}) { picture_url }
      render_view
    end

    context "when only width or width and height are set" do
      let(:srcset) do
        %w[1024x768 800x]
      end

      it "adds srcset attribute including image url and width for each size" do
        url1 = ingredient.picture_url(size: "1024x768")
        url2 = ingredient.picture_url(size: "800x")
        render_view
        expect(page).to have_selector("img[srcset=\"#{url1} 1024w, #{url2} 800w\"]")
      end
    end

    context "when only height is set" do
      let(:srcset) do
        %w[x768 x600]
      end

      it "adds srcset attribute including image url and height for each size" do
        url1 = ingredient.picture_url(size: "x768")
        url2 = ingredient.picture_url(size: "x600")
        render_view
        expect(page).to have_selector("img[srcset=\"#{url1} 768h, #{url2} 600h\"]")
      end
    end
  end

  context "with no srcset ingredient setting" do
    subject!(:render_view) do
      render_inline described_class.new(ingredient)
    end

    it "image tag has no srcset attribute" do
      expect(page).not_to have_selector("img[srcset]")
    end
  end

  context "with sizes ingredient setting" do
    before do
      allow(ingredient).to receive(:settings) do
        {sizes: sizes}
      end
    end

    subject(:render_view) do
      render_inline described_class.new(ingredient)
    end

    let(:sizes) do
      [
        "(max-width: 1023px) 100vh",
        "(min-width: 1024px) 33.333vh"
      ]
    end

    it "does not pass sizes option to picture_url" do
      expect(ingredient).to receive(:picture_url).with({}) { picture_url }
      render_view
    end

    it "adds sizes attribute for each size" do
      render_view
      expect(page).to have_selector("img[sizes=\"#{sizes[0]}, #{sizes[1]}\"]")
    end
  end

  context "with no sizes ingredient setting" do
    subject!(:render_view) do
      render_inline described_class.new(ingredient)
    end

    it "image tag has no sizes attribute" do
      expect(page).not_to have_selector("img[sizes]")
    end
  end

  describe "alt text" do
    subject!(:render_view) do
      render_inline described_class.new(ingredient, html_options: html_options)
    end

    let(:html_options) { {} }

    context "ingredient having alt text stored" do
      let(:ingredient) do
        stub_model Alchemy::Ingredients::Picture,
          picture: picture,
          alt_tag: "A cute cat"
      end

      it "uses this as image alt text" do
        expect(page).to have_selector('img[alt="A cute cat"]')
      end
    end

    context "ingredient not having alt text stored" do
      context "but passed as html option" do
        let(:html_options) { {alt: "Cute kittens"} }

        it "uses this as image alt text" do
          expect(page).to have_selector('img[alt="Cute kittens"]')
        end
      end

      context "and not passed as html option" do
        context "with name on the picture" do
          let(:picture) do
            stub_model Alchemy::Picture,
              image_file_format: "png",
              image_file: image,
              name: "cute_kitty-cat"
          end

          it "uses a humanized picture name as alt text" do
            expect(page).to have_selector('img[alt="Cute kitty-cat"]')
          end
        end

        context "and no name on the picture" do
          it "has no alt text" do
            expect(page).to_not have_selector("img[alt]")
          end
        end
      end
    end
  end
end
