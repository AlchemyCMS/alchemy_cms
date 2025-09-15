# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe Picture do
    let :image_file do
      fixture_file_upload("image.png")
    end

    let(:picture) { build(:alchemy_picture, image_file: image_file) }

    if Alchemy.storage_adapter.dragonfly?
      it_behaves_like "having file name sanitization" do
        subject { Picture.new(image_file:) }
        let(:file_name_attribute) { :image_file_name }
      end
    end

    it_behaves_like "a relatable resource",
      resource_name: :picture,
      ingredient_type: :picture

    it "is valid with valid attributes" do
      expect(picture).to be_valid
    end

    it "is not valid without image file" do
      picture = build(:alchemy_picture, image_file: nil)
      expect(picture).not_to be_valid
    end

    it "is not valid with an invalid image file" do
      picture = build(:alchemy_picture, image_file: fixture_file_upload("file.pdf"))
      expect(picture).to_not be_valid
      expect(picture.errors[:image_file]).to include("This is not an valid image.")
    end

    it "is valid with capitalized image file extension" do
      picture = build(:alchemy_picture, image_file: fixture_file_upload("image2.PNG"))
      expect(picture).to be_valid
    end

    it "is valid with jpeg image file extension" do
      picture = build(:alchemy_picture, image_file: fixture_file_upload("image3.jpeg"))
      expect(picture).to be_valid
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

    describe ".searchable_alchemy_resource_attributes" do
      it "delegates to storage adapter" do
        expect(Alchemy.storage_adapter).to receive(:searchable_alchemy_resource_attributes).with("Alchemy::Picture")
        described_class.searchable_alchemy_resource_attributes
      end
    end

    describe ".ransackable_attributes" do
      it "delegates to storage adapter" do
        expect(Alchemy.storage_adapter).to receive(:ransackable_attributes).with("Alchemy::Picture")
        described_class.ransackable_attributes
      end
    end

    describe ".ransackable_associations" do
      it "delegates to storage adapter" do
        expect(Alchemy.storage_adapter).to receive(:ransackable_associations).with("Alchemy::Picture")
        described_class.ransackable_associations
      end
    end

    describe ".preprocessor_class" do
      it "delegates to storage adapter" do
        expect(Alchemy.storage_adapter).to receive(:preprocessor_class)
        described_class.preprocessor_class
      end
    end

    describe ".last_upload" do
      it "should return all pictures that have the same upload-hash as the most recent picture" do
        other_upload = create(:alchemy_picture, image_file: image_file, upload_hash: "456")
        same_upload = create(:alchemy_picture, image_file: image_file, upload_hash: "123")
        most_recent = create(:alchemy_picture, image_file: image_file, upload_hash: "123")

        expect(Picture.last_upload).to include(most_recent)
        expect(Picture.last_upload).to include(same_upload)
        expect(Picture.last_upload).not_to include(other_upload)

        [other_upload, same_upload, most_recent].each(&:destroy)
      end
    end

    describe ".recent" do
      before do
        now = Time.current
        @recent = create(:alchemy_picture, image_file: image_file)
        @old_picture = create(:alchemy_picture, image_file: image_file)
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
      it "deligates to storage adapter" do
        expect(Alchemy.storage_adapter).to receive(:file_formats).with(described_class.name, scope: described_class.all)
        described_class.file_formats
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
      before do
        allow(Alchemy.storage_adapter).to receive(:image_file_width).and_return(1)
        allow(Alchemy.storage_adapter).to receive(:image_file_height).and_return(1)
      end

      it "should return the width and height in the format of '1024x768'" do
        expect(picture.image_file_dimensions).to eq("1x1")
      end
    end

    describe "#update_name_and_tag_list!" do
      let(:picture) { build(:alchemy_picture, image_file: image_file) }

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
        create(:alchemy_picture, name: "square", image_file: image)
      end

      let(:options) { {} }

      let(:url_class) { double(call: "/pictures/square.png") }

      before do
        allow(described_class.url_class).to receive(:new).with(picture) { url_class }
      end

      it "calls url_class with options" do
        url
        expect(url_class).to have_received(:call).with(options)
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
          expect(url_class).to receive(:call) do
            raise(Alchemy.storage_adapter.rescuable_errors)
          end
        end

        it { is_expected.to be_nil }
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
      let(:image_file) { fixture_file_upload("image.png") }
      let(:picture) { build(:alchemy_picture, image_file:) }

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
          let(:image_file) { fixture_file_upload("image.png") }

          it { is_expected.to be(true) }
        end

        context "but the image has no convertible format" do
          let(:image_file) { fixture_file_upload("icon.svg") }

          it { is_expected.to be(false) }
        end
      end
    end

    describe "#has_convertible_format?" do
      let(:picture) { described_class.new }

      subject { picture.has_convertible_format? }

      it "delegates to storage adapter" do
        expect(Alchemy.storage_adapter).to receive(:has_convertible_format?).with(picture)
        subject
      end
    end

    describe "#image_file_name" do
      let(:picture) { build(:alchemy_picture) }

      subject { picture.image_file_name }

      it "returns file name" do
        is_expected.to eq("image.png")
      end
    end

    describe "#image_file_format" do
      let(:picture) { build(:alchemy_picture) }

      subject { picture.image_file_format }

      it "returns file format" do
        is_expected.to eq("image/png")
      end
    end

    describe "#image_file_size" do
      let(:picture) { build(:alchemy_picture) }

      subject { picture.image_file_size }

      it "returns file bytesize" do
        is_expected.to eq(70)
      end
    end

    describe "dimensions" do
      let(:picture) { build(:alchemy_picture) }

      describe "#image_file_width" do
        subject { picture.image_file_width }

        it "returns image dimension width" do
          is_expected.to eq(1)
        end
      end

      describe "#image_file_height" do
        subject { picture.image_file_height }

        it "returns image dimension height" do
          is_expected.to eq(1)
        end
      end
    end

    describe "#image_file_extension" do
      let(:image_file) { fixture_file_upload("image2.PNG") }
      let(:picture) { build(:alchemy_picture, image_file:) }

      subject { picture.image_file_extension }

      it "returns file extension" do
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
