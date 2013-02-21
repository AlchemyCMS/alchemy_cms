# encoding: utf-8
require 'spec_helper'

module Alchemy
  describe Attachment do
    let(:file) { File.new(File.expand_path('../../support/image with spaces.png', __FILE__)) }
    let(:attachment) { Attachment.new(:file => file) }

    describe 'after create' do
      before { attachment.save! }

      it "should have a humanized name" do
        attachment.name.should == "Image with spaces"
      end

      it "should have a valid file_name" do
        attachment.file_name.should == "image-with-spaces.png"
      end

      after { attachment.destroy }
    end

    describe 'validations' do

      context "having a png, but only pdf allowed" do
        before { Config.stub!(:get).and_return({'allowed_filetypes' => {'attachments' => ['pdf']}}) }

        it "should not be valid" do
          attachment.should_not be_valid
        end
      end

      context "having a png and everything allowed" do
        before { Config.stub!(:get).and_return({'allowed_filetypes' => {'attachments' => ['*']}}) }

        it "should be valid" do
          attachment.should be_valid
        end
      end

    end

    describe 'urlname sanitizing' do
      context "with url characters in the filename" do
        subject { stub_model(Attachment, :file_name => 'f#%&cking cute kitten pic.png') }
        its(:urlname) { should == 'f-cking-cute-kitten-pic.png' }
      end

      context "with lot of dots in the name" do
        subject { stub_model(Attachment, :file_name => 'cute.kitten.pic.png') }
        its(:urlname) { should == 'cute-kitten-pic.png' }
      end

      context "with umlauts in the name" do
        subject { stub_model(Attachment, :file_name => 'süßes katzenbild.png') }
        its(:urlname) { should == 'suesses-katzenbild.png' }
      end
    end

    context 'PNG image' do
      subject { stub_model(Attachment, :file_name => 'kitten.png') }
      its(:extension) { should == "png" }
    end

    describe 'css classes' do
      context 'mp3 file' do
        subject { stub_model(Attachment, :file_mime_type => 'audio/mpeg') }
        its(:icon_css_class) { should == "audio" }
      end

      context 'png file' do
        subject { stub_model(Attachment, :file_mime_type => 'image/png') }
        its(:icon_css_class) { should == "image" }
      end

      context 'vcf file' do
        subject { stub_model(Attachment, :file_mime_type => 'application/vcard') }
        its(:icon_css_class) { should == "vcard" }
      end

      context 'zip file' do
        subject { stub_model(Attachment, :file_mime_type => 'application/zip') }
        its(:icon_css_class) { should == "archive" }
      end
    end

  end
end
