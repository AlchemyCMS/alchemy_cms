require 'spec_helper'

describe Alchemy::EssencePicture do

  it "should not store negative values for crop_from" do
    essence = Alchemy::EssencePicture.new(:crop_from => '-1x100')
    essence.save!
    essence.crop_from.should == "0x100"
  end

end
