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

  end
end
