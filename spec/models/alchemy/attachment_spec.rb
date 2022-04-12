# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe Attachment do
    let(:file) { File.expand_path("../../fixtures/image with spaces.png", __dir__) }
    let(:attachment) { build(:alchemy_attachment, file: file) }

    it "has file mime type accessor" do
      expect(attachment.file_mime_type).to eq("image/png")
    end

    describe "after save" do
      subject(:save) { attachment.save! }

      it "should have a humanized name" do
        save
        expect(attachment.name).to eq("image with spaces")
      end

      context "when file_name has not changed" do
        before do
          attachment.update(name: "image with spaces")
        end

        it "should not change name" do
          expect { save }.to_not change { attachment.name }
        end
      end

      context "assigned to contents" do
        let(:attachment) { create(:alchemy_attachment) }

        let(:content) do
          create(:alchemy_content, :essence_file)
        end

        before do
          content.essence.update(attachment: attachment)
          content.element.update_column(:updated_at, 3.hours.ago)
        end

        it "touches elements" do
          expect { attachment.update(name: "image with spaces") }.to change { attachment.elements.reload.first.updated_at }
        end
      end
    end

    describe "#url" do
      subject { attachment.url }

      context "without file" do
        let(:attachment) { build(:alchemy_attachment, file: nil) }

        it { is_expected.to be_nil }
      end

      context "with file" do
        let(:attachment) { create(:alchemy_attachment) }

        it "returns local path" do
          is_expected.to eq "/attachment/#{attachment.id}/show"
        end

        context "with download enabled" do
          subject { attachment.url(download: true) }

          it "returns local download path" do
            is_expected.to eq "/attachment/#{attachment.id}/download"
          end

          context "with extra params given" do
            subject do
              attachment.url(download: true, name: attachment.slug, format: attachment.suffix)
            end

            it "returns local download path with name and suffix" do
              is_expected.to eq "/attachment/#{attachment.id}/download/#{attachment.slug}.#{attachment.suffix}"
            end
          end
        end

        context "with download disabled" do
          subject { attachment.url(download: false) }

          it "returns local path" do
            is_expected.to eq "/attachment/#{attachment.id}/show"
          end

          context "with extra params given" do
            subject do
              attachment.url(download: false, name: attachment.slug, format: attachment.suffix)
            end

            it "returns local path with name and suffix" do
              is_expected.to eq "/attachment/#{attachment.id}/show/#{attachment.slug}.#{attachment.suffix}"
            end
          end
        end
      end
    end

    describe "urlname sanitizing" do
      subject { attachment.slug }

      before do
        expect(attachment).to receive(:file_name) { file_name }
      end

      context "unsafe url characters" do
        let(:file_name) { "f#%&cking cute kitten pic.png" }

        it "get escaped" do
          is_expected.to eq("f%23%25%26cking+cute+kitten+pic")
        end
      end

      context "format suffix from end of file name" do
        let(:file_name) { "pic.png.png" }

        it "gets removed" do
          is_expected.to eq("pic+png")
        end
      end

      context "dots" do
        let(:file_name) { "cute.kitten.pic.png" }

        it "get converted into escaped spaces" do
          is_expected.to eq("cute+kitten+pic")
        end
      end

      context "umlauts in the name" do
        let(:file_name) { "süßes katzenbild.png" }

        it "get escaped" do
          is_expected.to eq("s%C3%BC%C3%9Fes+katzenbild")
        end
      end
    end

    describe "validations" do
      context "having a png, but only pdf allowed" do
        before do
          stub_alchemy_config(:uploader, {
            "allowed_filetypes" => {
              "alchemy/attachments" => ["pdf"],
            },
          })
        end

        it "should not be valid" do
          expect(attachment).not_to be_valid
          expect(attachment.errors[:image_file]).to eq(["not a valid file"])
        end
      end

      context "having a png and everything allowed" do
        before do
          stub_alchemy_config(:uploader, {
            "allowed_filetypes" => {
              "alchemy/attachments" => ["*"],
            },
          })
        end

        it "should be valid" do
          expect(attachment).to be_valid
        end
      end

      context "having a filename with special characters" do
        before do
          attachment.file_name = "my FileNämü.pdf"
          attachment.save
        end

        it "should be valid" do
          expect(attachment).to be_valid
        end
      end
    end

    describe "#extension" do
      subject { attachment.extension }

      it { is_expected.to eq("png") }
    end

    describe "#icon_css_class" do
      subject { attachment.icon_css_class }

      before do
        expect(attachment).to receive(:file_mime_type) { mime_type }
      end

      context "mp3 file" do
        let(:mime_type) { "audio/mpeg" }

        it { is_expected.to eq("file-audio") }
      end

      context "video file" do
        let(:mime_type) { "video/mpeg" }

        it { is_expected.to eq("file-video") }
      end

      context "png file" do
        let(:mime_type) { "image/png" }

        it { is_expected.to eq("file-image") }
      end

      context "vcard file" do
        let(:mime_type) { "application/vcard" }

        it { is_expected.to eq("address-card") }
      end

      context "zip file" do
        let(:mime_type) { "application/zip" }

        it { is_expected.to eq("file-archive") }
      end

      context "photoshop file" do
        let(:mime_type) { "image/x-psd" }

        it { is_expected.to eq("file-image") }
      end

      context "text file" do
        let(:mime_type) { "text/plain" }

        it { is_expected.to eq("file-alt") }
      end

      context "rtf file" do
        let(:mime_type) { "application/rtf" }

        it { is_expected.to eq("file-alt") }
      end

      context "pdf file" do
        let(:mime_type) { "application/pdf" }

        it { is_expected.to eq("file-pdf") }
      end

      context "word file" do
        let(:mime_type) { "application/msword" }

        it { is_expected.to eq("file-word") }
      end

      context "excel file" do
        let(:mime_type) { "application/vnd.ms-excel" }

        it { is_expected.to eq("file-excel") }
      end

      context "xlsx file" do
        let(:mime_type) { "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" }

        it { is_expected.to eq("file-excel") }
      end

      context "csv file" do
        let(:mime_type) { "text/csv" }

        it { is_expected.to eq("file-excel") }
      end

      context "unknown file" do
        let(:mime_type) { "" }

        it { is_expected.to eq("file") }
      end
    end

    describe "#restricted?" do
      subject { attachment.restricted? }

      context "if only on restricted pages" do
        before do
          pages = double(any?: true)
          expect(pages).to receive(:not_restricted).and_return([])
          expect(attachment).to receive(:pages).twice.and_return(pages)
        end

        it { is_expected.to be_truthy }
      end

      context "if not only on restricted pages" do
        let(:page) { mock_model(Page) }

        before do
          pages = double(any?: true)
          expect(pages).to receive(:not_restricted).and_return([page])
          expect(attachment).to receive(:pages).twice.and_return(pages)
        end

        it { is_expected.to be_falsey }
      end
    end
  end
end
