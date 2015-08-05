# encoding: utf-8
require 'spec_helper'

module Alchemy
  describe Attachment do
    let(:file)       { File.new(File.expand_path('../../fixtures/image with spaces.png', __FILE__)) }
    let(:attachment) { Attachment.new(file: file) }

    describe 'after assign' do
      it "stores the file mime type into database" do
        attachment.update(file: file)
        expect(attachment.file_mime_type).not_to be_blank
      end
    end

    describe 'after create' do
      before { attachment.save! }

      it "should have a humanized name" do
        expect(attachment.name).to eq("image with spaces")
      end

      after { attachment.destroy }
    end

    describe 'urlname sanitizing' do
      it "escapes unsafe url characters" do
        attachment.file_name = 'f#%&cking cute kitten pic.png'
        expect(attachment.urlname).to eq('f%23%25%26cking+cute+kitten+pic')
      end

      it "removes format suffix from end of file name" do
        attachment.file_name = 'pic.png.png'
        expect(attachment.urlname).to eq('pic+png')
      end

      it "converts dots into escaped spaces" do
        attachment.file_name = 'cute.kitten.pic.png'
        expect(attachment.urlname).to eq('cute+kitten+pic')
      end

      it "escapes umlauts in the name" do
        attachment.file_name = 'süßes katzenbild.png'
        expect(attachment.urlname).to eq('s%C3%BC%C3%9Fes+katzenbild')
      end
    end

    describe 'validations' do

      context "having a png, but only pdf allowed" do
        before { allow(Config).to receive(:get).and_return({'allowed_filetypes' => {'attachments' => ['pdf']}}) }

        it "should not be valid" do
          expect(attachment).not_to be_valid
        end
      end

      context "having a png and everything allowed" do
        before { allow(Config).to receive(:get).and_return({'allowed_filetypes' => {'attachments' => ['*']}}) }

        it "should be valid" do
          expect(attachment).to be_valid
        end
      end

      context "having a filename with special characters" do
        before do
           attachment.file_name = 'my FileNämü.pdf'
           attachment.save
         end

        it "should be valid" do
          expect(attachment).to be_valid
        end
      end

      context "having a filename with unallowed character" do
        before do
          attachment.file_name = 'my FileNämü?!.pdf'
          attachment.save
        end

        it "should not be valid" do
          expect(attachment).not_to be_valid
        end
      end

    end

    context 'PNG image' do
      subject { stub_model(Attachment, file_name: 'kitten.png') }

      describe '#extension' do
        subject { super().extension }
        it { is_expected.to eq("png") }
      end
    end

    describe 'css classes' do
      context 'mp3 file' do
        subject { stub_model(Attachment, file_mime_type: 'audio/mpeg') }

        describe '#icon_css_class' do
          subject { super().icon_css_class }
          it { is_expected.to eq("audio") }
        end
      end

      context 'video file' do
        subject { stub_model(Attachment, file_mime_type: 'video/mpeg') }

        describe '#icon_css_class' do
          subject { super().icon_css_class }
          it { is_expected.to eq("video") }
        end
      end

      context 'png file' do
        subject { stub_model(Attachment, file_mime_type: 'image/png') }

        describe '#icon_css_class' do
          subject { super().icon_css_class }
          it { is_expected.to eq("image") }
        end
      end

      context 'vcf file' do
        subject { stub_model(Attachment, file_mime_type: 'application/vcard') }

        describe '#icon_css_class' do
          subject { super().icon_css_class }
          it { is_expected.to eq("vcard") }
        end
      end

      context 'zip file' do
        subject { stub_model(Attachment, file_mime_type: 'application/zip') }

        describe '#icon_css_class' do
          subject { super().icon_css_class }
          it { is_expected.to eq("archive") }
        end
      end

      context 'flash file' do
        subject { stub_model(Attachment, file_mime_type: 'application/x-shockwave-flash') }

        describe '#icon_css_class' do
          subject { super().icon_css_class }
          it { is_expected.to eq("flash") }
        end
      end

      context 'photoshop file' do
        subject { stub_model(Attachment, file_mime_type: 'image/x-psd') }

        describe '#icon_css_class' do
          subject { super().icon_css_class }
          it { is_expected.to eq("psd") }
        end
      end

      context 'text file' do
        subject { stub_model(Attachment, file_mime_type: 'text/plain') }

        describe '#icon_css_class' do
          subject { super().icon_css_class }
          it { is_expected.to eq("text") }
        end
      end

      context 'rtf file' do
        subject { stub_model(Attachment, file_mime_type: 'application/rtf') }

        describe '#icon_css_class' do
          subject { super().icon_css_class }
          it { is_expected.to eq("rtf") }
        end
      end

      context 'pdf file' do
        subject { stub_model(Attachment, file_mime_type: 'application/pdf') }

        describe '#icon_css_class' do
          subject { super().icon_css_class }
          it { is_expected.to eq("pdf") }
        end
      end

      context 'word file' do
        subject { stub_model(Attachment, file_mime_type: 'application/msword') }

        describe '#icon_css_class' do
          subject { super().icon_css_class }
          it { is_expected.to eq("word") }
        end
      end

      context 'excel file' do
        subject { stub_model(Attachment, file_mime_type: 'application/vnd.ms-excel') }

        describe '#icon_css_class' do
          subject { super().icon_css_class }
          it { is_expected.to eq("excel") }
        end
      end

      context 'unknown file' do
        subject { stub_model(Attachment, file_mime_type: '') }

        describe '#icon_css_class' do
          subject { super().icon_css_class }
          it { is_expected.to eq("file") }
        end
      end
    end

    describe '#restricted?' do
      subject { attachment.restricted? }

      context 'if only on restricted pages' do
        before do
          pages = double(any?: true)
          expect(pages).to receive(:not_restricted).and_return([])
          expect(attachment).to receive(:pages).twice.and_return(pages)
        end

        it { is_expected.to be_truthy }
      end

      context 'if not only on restricted pages' do
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
