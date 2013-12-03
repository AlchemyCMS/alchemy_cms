# encoding: utf-8
require 'spec_helper'

module Alchemy
  describe Attachment do
    let(:file)       { File.new(File.expand_path('../../fixtures/image with spaces.png', __FILE__)) }
    let(:attachment) { Attachment.new(file: file) }

    describe 'after assign' do
      it "stores the file mime type into database" do
        attachment.update(file: file)
        attachment.file_mime_type.should_not be_blank
      end
    end

    describe 'after create' do
      before { attachment.save! }

      it "should have a humanized name" do
        attachment.name.should == "image with spaces"
      end

      it "should have a valid file_name" do
        attachment.file_name.should == "image-with-spaces.png"
      end

      after { attachment.destroy }
    end

    describe 'urlname sanitizing' do
      it "should sanitize url characters in the filename" do
        attachment.file_name = 'f#%&cking cute kitten pic.png'
        attachment.save!
        attachment.urlname.should == 'f-cking-cute-kitten-pic.png'
      end

      it "should sanitize lot of dots in the name" do
        attachment.file_name = 'cute.kitten.pic.png'
        attachment.save!
        attachment.urlname.should == 'cute-kitten-pic.png'
      end

      it "should sanitize umlauts in the name" do
        attachment.file_name = 'süßes katzenbild.png'
        attachment.save!
        attachment.urlname.should == 'suesses-katzenbild.png'
      end

      after { attachment.destroy }
    end

    describe 'validations' do

      context "having a png, but only pdf allowed" do
        before { Config.stub(:get).and_return({'allowed_filetypes' => {'attachments' => ['pdf']}}) }

        it "should not be valid" do
          attachment.should_not be_valid
        end
      end

      context "having a png and everything allowed" do
        before { Config.stub(:get).and_return({'allowed_filetypes' => {'attachments' => ['*']}}) }

        it "should be valid" do
          attachment.should be_valid
        end
      end

    end

    context 'PNG image' do
      subject { stub_model(Attachment, file_name: 'kitten.png') }
      its(:extension) { should == "png" }
    end

    describe 'css classes' do
      context 'mp3 file' do
        subject { stub_model(Attachment, file_mime_type: 'audio/mpeg') }
        its(:icon_css_class) { should == "audio" }
      end

      context 'video file' do
        subject { stub_model(Attachment, file_mime_type: 'video/mpeg') }
        its(:icon_css_class) { should == "video" }
      end

      context 'png file' do
        subject { stub_model(Attachment, file_mime_type: 'image/png') }
        its(:icon_css_class) { should == "image" }
      end

      context 'vcf file' do
        subject { stub_model(Attachment, file_mime_type: 'application/vcard') }
        its(:icon_css_class) { should == "vcard" }
      end

      context 'zip file' do
        subject { stub_model(Attachment, file_mime_type: 'application/zip') }
        its(:icon_css_class) { should == "archive" }
      end

      context 'flash file' do
        subject { stub_model(Attachment, file_mime_type: 'application/x-shockwave-flash') }
        its(:icon_css_class) { should == "flash" }
      end

      context 'photoshop file' do
        subject { stub_model(Attachment, file_mime_type: 'image/x-psd') }
        its(:icon_css_class) { should == "psd" }
      end

      context 'text file' do
        subject { stub_model(Attachment, file_mime_type: 'text/plain') }
        its(:icon_css_class) { should == "text" }
      end

      context 'rtf file' do
        subject { stub_model(Attachment, file_mime_type: 'application/rtf') }
        its(:icon_css_class) { should == "rtf" }
      end

      context 'pdf file' do
        subject { stub_model(Attachment, file_mime_type: 'application/pdf') }
        its(:icon_css_class) { should == "pdf" }
      end

      context 'word file' do
        subject { stub_model(Attachment, file_mime_type: 'application/msword') }
        its(:icon_css_class) { should == "word" }
      end

      context 'excel file' do
        subject { stub_model(Attachment, file_mime_type: 'application/vnd.ms-excel') }
        its(:icon_css_class) { should == "excel" }
      end

      context 'unknown file' do
        subject { stub_model(Attachment, file_mime_type: '') }
        its(:icon_css_class) { should == "file" }
      end
    end

    describe '#restricted?' do
      subject { attachment.restricted? }

      context 'if only on restricted pages' do
        before do
          pages = double(any?: true)
          pages.should_receive(:not_restricted).and_return([])
          attachment.should_receive(:pages).twice.and_return(pages)
        end

        it { should be_true }
      end

      context 'if not only on restricted pages' do
        let(:page) { mock_model(Page) }

        before do
          pages = double(any?: true)
          pages.should_receive(:not_restricted).and_return([page])
          attachment.should_receive(:pages).twice.and_return(pages)
        end

        it { should be_false }
      end
    end

  end
end
