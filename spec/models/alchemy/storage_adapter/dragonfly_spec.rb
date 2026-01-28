require "rails_helper"

RSpec.describe Alchemy::StorageAdapter::Dragonfly, if: Alchemy.storage_adapter.dragonfly? do
  describe "relations and callbacks" do
    it { expect(Alchemy::Picture.new).to have_many(:thumbs).class_name("Alchemy::PictureThumb") }

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
  end

  describe "Picture preprocessing" do
    context "with enabled preprocess_image_resize config option" do
      let(:image_file) do
        fixture_file_upload("80x60.png")
      end

      context "with > geometry string" do
        before do
          allow(Alchemy.config).to receive(:preprocess_image_resize) do
            "10x10>"
          end
        end

        it "it resizes the image after upload" do
          picture = Alchemy::Picture.new(image_file: image_file)
          expect(picture.image_file.data[0x10..0x18].unpack("NN")).to eq([10, 8])
        end
      end

      context "without > geometry string" do
        before do
          allow(Alchemy.config).to receive(:preprocess_image_resize) do
            "10x10"
          end
        end

        it "it resizes the image after upload" do
          picture = Alchemy::Picture.new(image_file: image_file)
          expect(picture.image_file.data[0x10..0x18].unpack("NN")).to eq([10, 8])
        end
      end
    end
  end

  describe ".attachment_url_class" do
    subject { described_class.attachment_url_class }

    it { is_expected.to eq(Alchemy::StorageAdapter::Dragonfly::AttachmentUrl) }
  end

  describe ".attachment_url_class=" do
    let(:custom_class) { Class.new }

    subject { described_class.attachment_url_class }

    around do |example|
      described_class.attachment_url_class = custom_class
      example.run
      described_class.attachment_url_class = nil
    end

    it { is_expected.to eq(custom_class) }
  end

  describe ".picture_url_class" do
    subject { described_class.picture_url_class }

    it { is_expected.to eq(Alchemy::StorageAdapter::Dragonfly::PictureUrl) }
  end

  describe ".picture_url_class=" do
    let(:custom_class) { Class.new }

    subject { described_class.picture_url_class }

    around do |example|
      described_class.picture_url_class = custom_class
      example.run
      described_class.picture_url_class = nil
    end

    it { is_expected.to eq(custom_class) }
  end

  describe ".file_formats" do
    subject(:file_formats) do
      described_class.file_formats(class_name, scope: scope)
    end

    context "for a Alchemy::Picture" do
      let(:class_name) { "Alchemy::Picture" }
      let(:scope) { Alchemy::Picture.all }

      let!(:picture1) { create(:alchemy_picture, name: "Ping", image_file: fixture_file_upload("image.png")) }
      let!(:picture2) { create(:alchemy_picture, name: "Jay Peg", image_file: fixture_file_upload("image3.jpeg")) }

      it "should return all picture file formats" do
        is_expected.to match_array(["jpeg", "png"])
      end

      context "with a scope" do
        let(:scope) { Alchemy::Picture.where(name: "Jay Peg") }

        it "should only return scoped picture file formats" do
          is_expected.to eq(["jpeg"])
        end
      end

      context "with from_extensions" do
        subject(:file_formats) do
          described_class.file_formats(class_name, scope: scope, from_extensions: ["jpeg"])
        end

        it "should return only matching picture file formats" do
          is_expected.to eq(["jpeg"])
        end
      end
    end

    context "for a Alchemy::Attachment" do
      let(:class_name) { "Alchemy::Attachment" }
      let(:scope) { Alchemy::Attachment.all }

      let!(:attachment1) do
        create(:alchemy_attachment, name: "Pee Dee Eff", file: fixture_file_upload("file.pdf"))
      end

      let!(:attachment2) do
        create(:alchemy_attachment, name: "Zip File", file: fixture_file_upload("archive.zip"))
      end

      it "should return all attachment file formats" do
        is_expected.to match_array [
          "application/pdf",
          "application/zip"
        ]
      end

      context "with a scope" do
        let(:scope) { Alchemy::Attachment.where(name: "Pee Dee Eff") }

        it "should only return scoped attachment file formats" do
          is_expected.to eq ["application/pdf"]
        end
      end

      context "with from_extensions" do
        subject(:file_formats) do
          described_class.file_formats(class_name, scope: scope, from_extensions: ["pdf"])
        end

        it "should return only matching attachment file formats" do
          is_expected.to eq(["application/pdf"])
        end
      end
    end
  end

  describe ".searchable_alchemy_resource_attributes" do
    subject { described_class.searchable_alchemy_resource_attributes(class_name) }

    context "for Alchemy::Picture" do
      let(:class_name) { "Alchemy::Picture" }

      it "returns an array of attributes for the search field query" do
        is_expected.to eq(%w[name image_file_name])
      end
    end

    context "for Alchemy::Attachment" do
      let(:class_name) { "Alchemy::Attachment" }

      it "returns an array of attributes for the search field query" do
        is_expected.to eq(%w[name file_name])
      end
    end
  end

  describe ".ransackable_associations" do
    subject { described_class.ransackable_associations("not_used") }

    it { is_expected.to eq(%w[]) }
  end

  describe ".ransackable_attributes" do
    subject { described_class.ransackable_attributes(class_name) }

    context "for an Alchemy::Attachment" do
      let(:class_name) { "Alchemy::Attachment" }

      it "returns an array of ransackable attributes" do
        is_expected.to eq(%w[name file_name])
      end
    end

    context "for an Alchemy::Picture" do
      let(:class_name) { "Alchemy::Picture" }

      it "returns an array of ransackable attributes" do
        is_expected.to eq(%w[name image_file_name])
      end
    end
  end

  describe ".image_file_present?" do
    subject { described_class.image_file_present?(picture) }

    let(:picture) { Alchemy::Picture.new }

    context "when image_file is present" do
      before do
        expect(picture).to receive(:image_file) { fixture_file_upload("image.png") }
      end

      it { is_expected.to be(true) }
    end

    context "when image_file is not present" do
      before do
        expect(picture).to receive(:image_file) { nil }
      end

      it { is_expected.to be(false) }
    end
  end

  describe ".set_attachment_name?" do
    subject { described_class.set_attachment_name?(attachment) }

    let(:attachment) { Alchemy::Attachment.new }

    context "when file_name has changed" do
      before do
        expect(attachment).to receive(:file_name_changed?) { true }
      end

      it { is_expected.to be(true) }
    end

    context "when file_name has not changed" do
      before do
        expect(attachment).to receive(:file_name_changed?) { false }
      end

      it { is_expected.to be(false) }
    end
  end

  describe ".has_convertible_format?" do
    subject { Alchemy.storage_adapter.has_convertible_format?(picture) }

    context "for an convertible image" do
      let(:picture) { build(:alchemy_picture) }

      it { is_expected.to eq(true) }
    end

    context "for an non-convertible image" do
      let(:picture) { build(:alchemy_picture, image_file: fixture_file_upload("icon.svg")) }

      it { is_expected.to eq(false) }
    end
  end
end
