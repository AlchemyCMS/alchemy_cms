require 'spec_helper'

module Alchemy
  describe EssencePicture do

    it "should not store negative values for crop values" do
      essence = EssencePicture.new(:crop_from => '-1x100', :crop_size => '-20x30')
      essence.save!
      essence.crop_from.should == "0x100"
      essence.crop_size.should == "0x30"
    end

    it "should not store float values for crop values" do
      essence = EssencePicture.new(:crop_from => '0.05x104.5', :crop_size => '99.5x203.4')
      essence.save!
      essence.crop_from.should == "0x105"
      essence.crop_size.should == "100x203"
    end

    it "should convert newlines in caption into <br/>s" do
      essence = EssencePicture.new(:caption => "hello\nkitty")
      essence.save!
      essence.caption.should == "hello<br/>kitty"
    end

  end
end
