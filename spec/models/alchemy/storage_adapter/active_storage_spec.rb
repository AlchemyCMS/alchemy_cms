require "rails_helper"

RSpec.describe Alchemy::StorageAdapter::ActiveStorage, if: Alchemy.storage_adapter.active_storage? do
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
        is_expected.to match_array(["image/jpeg", "image/png"])
      end

      context "with a scope" do
        let(:scope) { Alchemy::Picture.where(name: "Jay Peg") }

        it "should only return scoped picture file formats" do
          is_expected.to eq(["image/jpeg"])
        end
      end

      context "with from_extensions" do
        subject(:file_formats) do
          described_class.file_formats(class_name, scope: scope, from_extensions: ["jpeg"])
        end

        it "should return only matching picture file formats" do
          is_expected.to eq(["image/jpeg"])
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
        is_expected.to eq(%w[name image_file_blob_filename])
      end
    end

    context "for Alchemy::Attachment" do
      let(:class_name) { "Alchemy::Attachment" }

      it "returns an array of attributes for the search field query" do
        is_expected.to eq(%w[name file_blob_filename])
      end
    end
  end

  describe ".ransackable_associations" do
    subject { described_class.ransackable_associations(class_name) }

    context "for Alchemy::Picture" do
      let(:class_name) { "Alchemy::Picture" }

      it "returns an array of ransackable associations" do
        is_expected.to eq(%w[image_file_blob])
      end
    end

    context "for Alchemy::Attachment" do
      let(:class_name) { "Alchemy::Attachment" }

      it "returns an array of ransackable associations" do
        is_expected.to eq(%w[file_blob])
      end
    end
  end

  describe ".image_file_present?" do
    subject { described_class.image_file_present?(picture) }

    let(:picture) { Alchemy::Picture.new }

    context "when image_file is present" do
      before do
        expect(picture.image_file).to receive(:attached?) { true }
      end

      it { is_expected.to be(true) }
    end

    context "when image_file is not present" do
      before do
        expect(picture.image_file).to receive(:attached?) { false }
      end

      it { is_expected.to be(false) }
    end
  end

  describe ".set_attachment_name?" do
    subject { described_class.set_attachment_name?(attachment) }

    let(:attachment) { Alchemy::Attachment.new }

    context "when file_name has changed" do
      before do
        expect(attachment.file).to receive(:changed?) { true }
      end

      it { is_expected.to be(true) }
    end

    context "when file_name has not changed" do
      before do
        expect(attachment.file).to receive(:changed?) { false }
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
