# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::Picture do
  it_behaves_like "an alchemy ingredient"

  let(:element) { build(:alchemy_element) }
  let(:picture) { build(:alchemy_picture) }

  let(:picture_ingredient) do
    described_class.new(
      element: element,
      type: described_class.name,
      role: "image",
      related_object: picture,
    )
  end

  describe "alt_tag" do
    before { picture_ingredient.alt_tag = "A cute kitten" }
    subject { picture_ingredient.alt_tag }

    it { is_expected.to eq("A cute kitten") }
  end

  describe "css_class" do
    before { picture_ingredient.css_class = "download" }
    subject { picture_ingredient.css_class }

    it { is_expected.to eq("download") }
  end

  describe "link_title" do
    before { picture_ingredient.link_title = "Nice picture" }
    subject { picture_ingredient.link_title }

    it { is_expected.to eq("Nice picture") }
  end

  describe "title" do
    before { picture_ingredient.title = "Click to view" }
    subject { picture_ingredient.title }

    it { is_expected.to eq("Click to view") }
  end

  describe "picture" do
    subject { picture_ingredient.picture }

    it { is_expected.to be_an(Alchemy::Picture) }
  end

  describe "picture=" do
    let(:picture) { Alchemy::Picture.new }

    subject { picture_ingredient.picture = picture }

    it { is_expected.to be(picture) }
  end

  describe "preview_text" do
    subject { picture_ingredient.preview_text }

    context "with a picture" do
      let(:picture) do
        Alchemy::Picture.new(name: "A very long picture name that would not fit")
      end

      it "returns first 30 characters of the picture name" do
        is_expected.to eq("A very long picture name that ")
      end
    end

    context "with no picture" do
      let(:picture) { nil }

      it { is_expected.to eq("") }
    end
  end

  describe "#picture_url" do
    subject(:picture_url) { picture_ingredient.picture_url(options) }

    let(:options) { {} }

    context "with no picture present" do
      let(:picture) { nil }

      it { is_expected.to be_nil }
    end

    context "with picture present" do
      let(:picture) { create(:alchemy_picture) }

      it "reads url from picture" do
        is_expected.to match(/\/pictures\/.+\/image\.png/)
      end

      context "with crop sizes in the options" do
        let(:options) do
          { crop_from: "30x30", crop_size: "75x75" }
        end

        it "passes these crop sizes to picture url." do
          expect(picture).to receive(:url).with(
            hash_including(crop_from: "30x30", crop_size: "75x75"),
          )
          picture_url
        end
      end

      context "with format in the options" do
        let(:options) { { format: "gif" } }

        it "takes this as format." do
          is_expected.to match(/\.gif/)
        end
      end

      context "with other options given" do
        let(:options) { { foo: "baz" } }

        it "adds them to the url" do
          is_expected.to match(/\?foo=baz/)
        end
      end

      context "if picture.url returns nil" do
        before do
          expect(picture).to receive(:url) { nil }
        end

        it "returns missing image url" do
          is_expected.to eq "missing-image.png"
        end
      end
    end
  end

  describe "#picture_url_options" do
    subject(:picture_url_options) { picture_ingredient.picture_url_options }

    let(:picture) { build_stubbed(:alchemy_picture) }

    it { is_expected.to be_a(HashWithIndifferentAccess) }

    it "includes the pictures default render format." do
      expect(picture).to receive(:default_render_format) { "img" }
      expect(picture_url_options[:format]).to eq("img")
    end

    context "with crop sizes present" do
      before do
        expect(picture_ingredient).to receive(:crop_size) { "200x200" }
        expect(picture_ingredient).to receive(:crop_from) { "10x10" }
      end

      it "includes these crop sizes.", :aggregate_failures do
        expect(picture_url_options[:crop_from]).to eq "10x10"
        expect(picture_url_options[:crop_size]).to eq "200x200"
      end
    end

    # Regression spec for issue #1279
    context "with crop sizes being empty strings" do
      before do
        expect(picture_ingredient).to receive(:crop_size) { "" }
        expect(picture_ingredient).to receive(:crop_from) { "" }
      end

      it "does not include these crop sizes.", :aggregate_failures do
        expect(picture_url_options[:crop_from]).to be_nil
        expect(picture_url_options[:crop_size]).to be_nil
      end
    end

    context "with ingredient having size setting" do
      before do
        expect(picture_ingredient).to receive(:settings) { { size: "30x70" } }
      end

      it "includes this size." do
        expect(picture_url_options[:size]).to eq "30x70"
      end
    end

    context "without picture assigned" do
      let(:picture) { nil }

      it { is_expected.to be_a(Hash) }
    end
  end

  describe "#allow_image_cropping?" do
    subject { picture_ingredient.allow_image_cropping? }

    context "if disabled in the settings" do
      it { is_expected.to be_falsy }
    end

    context "if enabled in settings" do
      before do
        expect(picture_ingredient).to receive(:settings).at_least(:once) { { crop: true } }
      end

      context "but with no picture assigned" do
        let(:picture) { nil }

        it { is_expected.to be_falsy }
      end

      context "with picture assigned" do
        context "and with image smaller than desired size" do
          before do
            expect(picture).to receive(:can_be_cropped_to?) { false }
          end

          it { is_expected.to be_falsy }
        end

        context "and with image larger than desired size" do
          before do
            expect(picture).to receive(:can_be_cropped_to?) { true }
          end

          context "if picture has no image attached" do
            before do
              expect(picture).to receive(:image_file) { nil }
            end

            it { is_expected.to be_falsy }
          end

          context "if picture.image_file is present" do
            let(:picture) { build_stubbed(:alchemy_picture) }

            it { is_expected.to be(true) }
          end
        end
      end
    end
  end
end
