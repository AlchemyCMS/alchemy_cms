require 'spec_helper'

module Alchemy
  describe Attachment do

    describe '#urlname' do

      context "with url characters in the filename" do
        subject { Attachment.new(:filename => 'f#%&cking cute kitten pic.png') }

        it "should escape as uri" do
          subject.urlname.should == 'f___cking_cute_kitten_pic.png'
        end
      end

      context "with lot of dots in the name" do
        subject { Attachment.new(:filename => 'cute.kitten.pic.png') }

        it "should convert dots in the name part into dashes" do
          subject.urlname.should == 'cute-kitten-pic.png'
        end
      end

    end

    context 'mp3 file' do
      subject { stub_model(Attachment, :content_type => 'audio/mpeg') }
      its(:icon_css_class) { should == "audio" }
    end

    context 'png file' do
      subject { stub_model(Attachment, :content_type => 'image/png') }
      its(:icon_css_class) { should == "image" }
    end

    context 'vcf file' do
      subject { stub_model(Attachment, :content_type => 'application/vcard') }
      its(:icon_css_class) { should == "vcard" }
    end

    context 'zip file' do
      subject { stub_model(Attachment, :content_type => 'application/zip') }
      its(:icon_css_class) { should == "archive" }
    end

  end
end
