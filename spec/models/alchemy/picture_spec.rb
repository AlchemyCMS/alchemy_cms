# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe Picture do
    let :image_file do
      File.new(File.expand_path("../../fixtures/image.png", __dir__))
    end

    let(:picture) { Picture.new }

    it_behaves_like "has image calculations"

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
        File.new(File.expand_path("../../fixtures/icon.svg", __dir__))
      end

      it "does not generate any thumbnails" do
        expect {
          create(:alchemy_picture, image_file: image_file)
        }.to_not change { Alchemy::PictureThumb.count }
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

    it "is valid with capitalized image file extension" do
      image_file = File.new(File.expand_path("../../fixtures/image2.PNG", __dir__))
      picture = Picture.new(image_file: image_file)
      expect(picture).to be_valid
    end

    it "is valid with jpeg image file extension" do
      image_file = File.new(File.expand_path("../../fixtures/image3.jpeg", __dir__))
      picture = Picture.new(image_file: image_file)
      expect(picture).to be_valid
    end

    context "with enabled preprocess_image_resize config option" do
      let(:image_file) do
        File.new(File.expand_path("../../fixtures/80x60.png", __dir__))
      end

      context "with > geometry string" do
        before do
          allow(Config).to receive(:get) do |arg|
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
          allow(Config).to receive(:get) do |arg|
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
        pic = stub_model(Picture, image_file_name: "kitten.JPG")
        allow(pic).to receive(:image_file).and_return(OpenStruct.new({ ext: "jpg" }))
        expect(pic.suffix).to eq("jpg")
      end

      context "image has no suffix" do
        it "should return empty string" do
          pic = stub_model(Picture, image_file_name: "kitten")
          allow(pic).to receive(:image_file).and_return(OpenStruct.new({ ext: "" }))
          expect(pic.suffix).to eq("")
        end
      end
    end

    describe "#humanized_name" do
      it "should return a humanized version of original filename" do
        pic = stub_model(Picture, image_file_name: "cute_kitten.JPG")
        allow(pic).to receive(:image_file).and_return(OpenStruct.new({ ext: "jpg" }))
        expect(pic.humanized_name).to eq("cute kitten")
      end

      it "should not remove incidents of suffix from filename" do
        pic = stub_model(Picture, image_file_name: "cute_kitten_mo.jpgi.JPG")
        allow(pic).to receive(:image_file).and_return(OpenStruct.new({ ext: "jpg" }))
        expect(pic.humanized_name).to eq("cute kitten mo.jpgi")
        expect(pic.humanized_name).not_to eq("cute kitten moi")
      end

      context "image has no suffix" do
        it "should return humanized name" do
          pic = stub_model(Picture, image_file_name: "cute_kitten")
          allow(pic).to receive(:suffix).and_return("")
          expect(pic.humanized_name).to eq("cute kitten")
        end
      end
    end

    describe ".search_by" do
      subject(:search_by) { Picture.search_by(params, query, per_page) }

      let(:pictures) { Picture.all }
      let(:params) { ActionController::Parameters.new }
      let(:query) { double(result: pictures) }
      let(:per_page) { nil }

      it "orders the result by name" do
        expect(pictures).to receive(:order).with(:name)
        search_by
      end

      context "with per_page given" do
        let(:per_page) { 10 }

        context "without page parameter given" do
          it "paginates the records" do
            expect(pictures).to receive(:page).with(1).and_call_original
            search_by
          end
        end

        context "with page parameter given" do
          let(:params) do
            ActionController::Parameters.new(page: 2)
          end

          it "paginates the records" do
            expect(pictures).to receive(:page).with(2).and_call_original
            search_by
          end
        end
      end

      context "when params[:filter] is set" do
        let(:params) do
          ActionController::Parameters.new(filter: "recent")
        end

        it "filters the pictures collection by the given filter string" do
          expect(pictures).to \
            receive(:filtered_by).with(params["filter"]).and_call_original
          search_by
        end
      end

      context "when params[:tagged_with] is set" do
        let(:params) do
          ActionController::Parameters.new(tagged_with: "kitten")
        end

        it "filters the records by tags" do
          expect(pictures).to \
            receive(:tagged_with).with(params["tagged_with"]).and_call_original
          search_by
        end
      end
    end

    describe ".filtered_by" do
      let(:picture) { build_stubbed(:alchemy_picture) }

      context "with 'recent' as argument" do
        it "should call the .recent scope" do
          expect(Picture).to receive(:recent).and_return(picture)
          expect(Picture.filtered_by("recent")).to eq(picture)
        end
      end

      context "with 'last_upload' as argument" do
        it "should call the .last_upload scope" do
          expect(Picture).to receive(:last_upload).and_return(picture)
          expect(Picture.filtered_by("last_upload")).to eq(picture)
        end
      end

      context "with 'without_tag' as argument" do
        it "should call the .without_tag scope" do
          expect(Picture).to receive(:without_tag).and_return(picture)
          expect(Picture.filtered_by("without_tag")).to eq(picture)
        end
      end

      context "with no argument" do
        it "should return the scoped collection" do
          expect(Picture).to receive(:all).and_return(picture)
          expect(Picture.filtered_by("")).to eq(picture)
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

    describe "#destroy" do
      context "a picture that is assigned in an essence" do
        let(:essence_picture) { EssencePicture.create }
        let(:picture) { create :alchemy_picture }

        before do
          essence_picture.update_columns(picture_id: picture.id)
        end

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
        picture.update_name_and_tag_list!({ pictures_tag_list: "Foo" })
      end

      context "name is present" do
        it "updates name" do
          expect(picture).to receive(:name=).with("Foo")
          picture.update_name_and_tag_list!({ pictures_name: "Foo" })
        end
      end

      context "name is not present" do
        it "does not update name" do
          expect(picture).not_to receive(:name=).with("Foo")
          picture.update_name_and_tag_list!({ pictures_name: "" })
        end
      end
    end

    describe "#url" do
      subject(:url) { picture.url(options) }

      let(:image) do
        fixture_file_upload(
          File.expand_path("../../fixtures/500x500.png", __dir__),
          "image/png",
        )
      end

      let(:picture) do
        create(:alchemy_picture, image_file: image)
      end

      let(:options) { Hash.new }

      it "includes the name and render format" do
        expect(url).to match /\/#{picture.name}\.#{picture.default_render_format}/
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
              size: "10x10",
            }
          end

          it "does not pass them to the URL" do
            expect(url).to_not match /crop/
          end

          it "returns the url to the thumbnail" do
            is_expected.to match(/\/pictures\/\d+\/.+\/500x500\.png/)
          end
        end

        context "that are params" do
          let(:options) do
            {
              page: 1,
              per_page: 10,
            }
          end

          it "passes them to the URL" do
            expect(url).to match /page=1/
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

    describe "#to_jq_upload" do
      subject { picture.to_jq_upload }

      let(:picture) { build_stubbed(:alchemy_picture, image_file_name: "cute-kittens.jpg", image_file_size: 1024) }

      it "returns a hash containing data for jquery fileuploader" do
        is_expected.to be_an_instance_of(Hash)
        is_expected.to include(name: picture.image_file_name)
        is_expected.to include(size: picture.image_file_size)
      end

      context "with error" do
        let(:picture) { build_stubbed(:alchemy_picture) }

        before do
          expect(picture).to receive(:errors).and_return({ image_file: %w(stupid_cats) })
        end

        it "returns hash with error message" do
          is_expected.to be_an_instance_of(Hash)
          is_expected.to include(error: "stupid_cats")
        end
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
                any?: true,
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
                any?: true,
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

    context "navigating records" do
      let!(:picture1) { create(:alchemy_picture, name: "abc") }
      let!(:picture2) { create(:alchemy_picture, name: "def") }

      describe "#previous" do
        subject { picture2.previous }

        it "returns the previous record by name" do
          is_expected.to eq(picture1)
        end
      end

      describe "#next" do
        subject { picture1.next }

        it "returns the next record by name" do
          is_expected.to eq(picture2)
        end
      end
    end

    describe "#default_render_format" do
      let(:picture) do
        Picture.new(image_file_format: "png")
      end

      subject { picture.default_render_format }

      context "when `image_output_format` is configured to `original`" do
        before do
          stub_alchemy_config(:image_output_format, "original")
        end

        it "returns the image file format" do
          is_expected.to eq("png")
        end
      end

      context "when `image_output_format` is configured to an image format" do
        before do
          stub_alchemy_config(:image_output_format, "jpg")
        end

        context "and the format is a convertible format" do
          it "returns the configured file format." do
            is_expected.to eq("jpg")
          end
        end

        context "but the format is not a convertible format" do
          before do
            allow(picture).to receive(:image_file_format) { "svg" }
          end

          it "returns the original file format." do
            is_expected.to eq("svg")
          end
        end
      end
    end

    describe "after update" do
      context "assigned to contents" do
        let(:picture) { create(:alchemy_picture) }

        let(:content) do
          create(:alchemy_content, :essence_picture)
        end

        before do
          content.essence.update(picture: picture)
          content.element.update_column(:updated_at, 3.hours.ago)
        end

        it "touches elements" do
          expect { picture.save }.to change { picture.elements.reload.first.updated_at }
        end
      end
    end
  end
end
