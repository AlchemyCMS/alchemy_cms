# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe Picture do
    let :image_file do
      fixture_file_upload("image.png")
    end

    let(:picture) { Picture.new }

    it { is_expected.to have_many(:thumbs).class_name("Alchemy::PictureThumb") }

    context "with a png file" do
      it "generates thumbnails after create" do
        expect {
          create(:alchemy_picture)
        }.to change { Alchemy::PictureThumb.count }.by(3)
      end
    end

    context "with a svg file" do
      let :image_file do
        fixture_file_upload("icon.svg")
      end

      it "does not generate any thumbnails" do
        expect {
          create(:alchemy_picture, image_file: image_file)
        }.to_not change { Alchemy::PictureThumb.count }
      end
    end

    context "with a webp file" do
      let :image_file do
        fixture_file_upload("image5.webp")
      end

      it "generates thumbnails after create" do
        expect {
          create(:alchemy_picture)
        }.to change { Alchemy::PictureThumb.count }.by(3)
      end
    end

    it "is valid with valid attributes" do
      picture = Picture.new(image_file: image_file)
      expect(picture).to be_valid
    end

    it "is not valid without image file" do
      picture = Picture.new
      expect(picture).not_to be_valid
    end

    it "is not valid with an invalid image file" do
      picture = build(:alchemy_picture, image_file: fixture_file_upload("file.pdf"))
      expect(picture).to_not be_valid
      expect(picture.errors[:image_file]).to include("This is not an valid image.")
    end

    it "is valid with capitalized image file extension" do
      image_file = fixture_file_upload("image2.PNG")
      picture = Picture.new(image_file: image_file)
      expect(picture).to be_valid
    end

    it "is valid with jpeg image file extension" do
      image_file = fixture_file_upload("image3.jpeg")
      picture = Picture.new(image_file: image_file)
      expect(picture).to be_valid
    end

    context "with enabled preprocess_image_resize config option" do
      let(:image_file) do
        fixture_file_upload("80x60.png")
      end

      context "with > geometry string" do
        before do
          allow(Alchemy.config).to receive(:get) do |arg|
            if arg == :preprocess_image_resize
              "10x10>"
            end
          end
        end

        it "it resizes the image after upload" do
          picture = Picture.new(image_file: image_file)
          expect(picture.image_file.data[0x10..0x18].unpack("NN")).to eq([10, 8])
        end
      end

      context "without > geometry string" do
        before do
          allow(Alchemy.config).to receive(:get) do |arg|
            if arg == :preprocess_image_resize
              "10x10"
            end
          end
        end

        it "it resizes the image after upload" do
          picture = Picture.new(image_file: image_file)
          expect(picture.image_file.data[0x10..0x18].unpack("NN")).to eq([10, 8])
        end
      end
    end

    describe "#suffix" do
      it "should return the suffix of original filename" do
        Alchemy::Deprecation.silenced do
          pic = build(:alchemy_picture)
          expect(pic.suffix).to eq("png")
        end
      end
    end

    describe "#humanized_name" do
      it "should return a humanized version of original filename" do
        allow(picture).to receive(:image_file_name).and_return("cute_kitten.JPG")
        allow(picture).to receive(:image_file_extension).and_return("jpg")
        expect(picture.humanized_name).to eq("cute kitten")
      end

      it "should not remove incidents of suffix from filename" do
        allow(picture).to receive(:image_file_name).and_return("cute_kitten_mo.jpgi.JPG")
        allow(picture).to receive(:image_file_extension).and_return("jpg")
        expect(picture.humanized_name).to eq("cute kitten mo.jpgi")
      end

      context "image has no suffix" do
        it "should return humanized name" do
          allow(picture).to receive(:image_file_name).and_return("cute_kitten")
          allow(picture).to receive(:image_file_extension).and_return("")
          expect(picture.humanized_name).to eq("cute kitten")
        end
      end
    end

    describe ".last_upload" do
      it "should return all pictures that have the same upload-hash as the most recent picture" do
        other_upload = Picture.create!(image_file: image_file, upload_hash: "456")
        same_upload = Picture.create!(image_file: image_file, upload_hash: "123")
        most_recent = Picture.create!(image_file: image_file, upload_hash: "123")

        expect(Picture.last_upload).to include(most_recent)
        expect(Picture.last_upload).to include(same_upload)
        expect(Picture.last_upload).not_to include(other_upload)

        [other_upload, same_upload, most_recent].each(&:destroy)
      end
    end

    describe ".recent" do
      before do
        now = Time.current
        @recent = Picture.create!(image_file: image_file)
        @old_picture = Picture.create!(image_file: image_file)
        @recent.update_column(:created_at, now - 23.hours)
        @old_picture.update_column(:created_at, now - 10.days)
      end

      it "should return all pictures that have been created in the last 24 hours" do
        expect(Picture.recent).to include(@recent)
      end

      it "should not return old pictures" do
        expect(Picture.recent).not_to include(@old_picture)
      end
    end

    describe ".file_formats" do
      let!(:picture1) { create(:alchemy_picture, name: "Ping", image_file: fixture_file_upload("image.png")) }
      let!(:picture2) { create(:alchemy_picture, name: "Jay Peg", image_file: fixture_file_upload("image3.jpeg")) }

      it "should return all picture file formats" do
        expect(Picture.file_formats).to match_array(%w[jpeg png])
      end

      context "with a scope" do
        it "should only return scoped picture file formats" do
          expect(Picture.file_formats(Picture.where(name: "Jay Peg"))).to eq(["jpeg"])
        end
      end
    end

    describe "#destroy" do
      context "a picture that is assigned to an ingredient" do
        let(:picture) { create(:alchemy_picture) }
        let!(:picture_ingredient) { create(:alchemy_ingredient_picture, related_object: picture) }

        it "should raise error message" do
          expect { picture.destroy }.to raise_error PictureInUseError
        end
      end
    end

    describe "#image_file_dimensions" do
      it "should return the width and height in the format of '1024x768'" do
        picture.image_file = image_file
        expect(picture.image_file_dimensions).to eq("1x1")
      end
    end

    describe "#update_name_and_tag_list!" do
      let(:picture) { Picture.new(image_file: image_file) }

      before { allow(picture).to receive(:save!).and_return(true) }

      it "updates tag_list" do
        expect(picture).to receive(:tag_list=).with("Foo")
        picture.update_name_and_tag_list!({pictures_tag_list: "Foo"})
      end

      context "name is present" do
        it "updates name" do
          expect(picture).to receive(:name=).with("Foo")
          picture.update_name_and_tag_list!({pictures_name: "Foo"})
        end
      end

      context "name is not present" do
        it "does not update name" do
          expect(picture).not_to receive(:name=).with("Foo")
          picture.update_name_and_tag_list!({pictures_name: ""})
        end
      end
    end

    describe "#url" do
      subject(:url) { picture.url(options) }

      let(:image) do
        fixture_file_upload("500x500.png")
      end

      let(:picture) do
        create(:alchemy_picture, image_file: image)
      end

      let(:options) { {} }

      it "includes the name and render format" do
        expect(url).to match(/\/#{picture.name}\.#{picture.default_render_format}/)
      end

      context "when no image is present" do
        before do
          expect(picture).to receive(:image_file) { nil }
        end

        it "returns nil" do
          expect(url).to be_nil
        end
      end

      context "when the image can not be fetched" do
        before do
          expect_any_instance_of(described_class.url_class).to receive(:call) do
            raise(::Dragonfly::Job::Fetch::NotFound)
          end
        end

        it { is_expected.to be_nil }
      end

      context "when options are passed" do
        context "that are transformation options" do
          let(:options) do
            {
              crop: true,
              size: "10x10"
            }
          end

          it "does not pass them to the URL" do
            expect(url).to_not match(/crop/)
          end

          it "returns the url to the thumbnail" do
            is_expected.to match(/\/pictures\/\d+\/.+\/500x500\.png/)
          end
        end

        context "that are params" do
          let(:options) do
            {
              page: 1,
              per_page: 10
            }
          end

          it "are not passed to the URL" do
            expect(url).to_not match(/page=1/)
          end
        end
      end
    end

    describe "#thumbnail_url" do
      subject(:thumbnail_url) { picture.thumbnail_url }

      let(:picture) do
        build(:alchemy_picture, image_file: image)
      end

      context "with no image file present" do
        let(:image) { nil }

        it { is_expected.to be_nil }
      end

      context "with image file present" do
        let(:image) do
          fixture_file_upload("500x500.png")
        end

        it "returns the url to the thumbnail" do
          expect(picture).to receive(:url).with(
            flatten: true,
            format: "png",
            size: "160x120"
          )
          thumbnail_url
        end

        context "with size given" do
          subject(:thumbnail_url) { picture.thumbnail_url(size: "800x600") }

          it "returns the url to the thumbnail" do
            expect(picture).to receive(:url).with(
              flatten: true,
              format: "png",
              size: "800x600"
            )
            thumbnail_url
          end
        end
      end
    end

    describe "#urlname" do
      subject { picture.urlname }

      let(:picture) { build_stubbed(:alchemy_picture, name: "Cute kittens.jpg") }

      it "returns a uri escaped name" do
        is_expected.to eq("Cute+kittens")
      end

      context "with blank name" do
        let(:picture) { build_stubbed(:alchemy_picture, name: "") }

        it "returns generic name" do
          is_expected.to eq("image_#{picture.id}")
        end
      end
    end

    describe "#description_for" do
      subject { picture.description_for(language) }

      let(:picture) { create(:alchemy_picture) }
      let(:language) { create(:alchemy_language) }

      context "with a description for the given language" do
        let!(:description) do
          Alchemy::PictureDescription.create!(
            picture: picture,
            language: language,
            text: "A nice picture"
          )
        end

        it { is_expected.to eq(description.text) }
      end

      context "without a description for the given language" do
        it { is_expected.to be_nil }
      end
    end

    describe "#restricted?" do
      subject { picture.restricted? }

      let(:picture) { build_stubbed(:alchemy_picture) }

      context "is assigned on pages" do
        context "that are all restricted" do
          before do
            expect(picture).to receive(:pages).at_least(:once) do
              double(
                not_restricted: double(blank?: true),
                any?: true
              )
            end
          end

          it { is_expected.to be_truthy }
        end

        context "that are not all restricted" do
          before do
            expect(picture).to receive(:pages).at_least(:once) do
              double(
                not_restricted: double(blank?: false),
                any?: true
              )
            end
          end

          it { is_expected.to be_falsey }
        end
      end

      context "is not assigned on any page" do
        before do
          expect(picture).to receive(:pages).and_return double(any?: false)
        end

        it { is_expected.to be_falsey }
      end
    end

    describe "#default_render_format" do
      let(:picture) { build(:alchemy_picture) }

      subject { picture.default_render_format }

      context "when image is convertible" do
        before do
          expect(picture).to receive(:convertible?) { true }
          stub_alchemy_config(:image_output_format, "jpg")
        end

        it "returns the configured image output format" do
          is_expected.to eq("jpg")
        end
      end

      context "when image is not convertible" do
        before do
          expect(picture).to receive(:convertible?) { false }
          stub_alchemy_config(:image_output_format, "original")
        end

        it "returns the original file format." do
          is_expected.to eq("png")
        end
      end
    end

    describe "#convertible?" do
      let(:picture) do
        Picture.new(image_file_format: "image/png")
      end

      subject { picture.convertible? }

      context "when `image_output_format` is configured to `original`" do
        before do
          stub_alchemy_config(:image_output_format, "original")
        end

        it { is_expected.to be(false) }
      end

      context "when `image_output_format` is configured to jpg" do
        before do
          stub_alchemy_config(:image_output_format, "jpg")
        end

        context "and the image has a convertible format" do
          before do
            expect(picture).to receive(:has_convertible_format?) { true }
          end

          it { is_expected.to be(true) }
        end

        context "but the image has no convertible format" do
          before do
            expect(picture).to receive(:has_convertible_format?) { false }
          end

          it { is_expected.to be(false) }
        end
      end
    end

    describe "#image_file_extension" do
      let(:image_file) { fixture_file_upload("image2.PNG") }
      let(:picture) { build(:alchemy_picture, image_file:) }

      subject { picture.image_file_extension }

      it "returns file extension by file format" do
        is_expected.to eq("png")
      end
    end

    describe "after update" do
      context "assigned to ingredient" do
        let(:picture) { create(:alchemy_picture) }

        let(:ingredient) do
          create(:alchemy_ingredient_picture, related_object: picture)
        end

        before do
          ingredient.element.update_column(:updated_at, 3.hours.ago)
        end

        it "touches elements" do
          expect { picture.save }.to change { picture.elements.reload.first.updated_at }
        end
      end
    end
  end
end
