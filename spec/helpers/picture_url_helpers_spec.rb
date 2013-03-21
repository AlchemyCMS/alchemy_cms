require 'spec_helper'

describe "Picture url helpers" do

  it "should generate a url string for cropped picture" do
    p = show_picture_path(:id => 3, :crop => "crop", :size => "100x33", :name => "kitten", :format => "jpg")
    p.should == "/pictures/3/show/100x33/crop/kitten.jpg"
  end

  it "should generate a url string for cropped and masked picture" do
    p = show_picture_path(:id => 3, :crop => "crop", :crop_from => "0x0", :crop_size => "900x300", :size => "100x33", :name => "kitten", :format => :jpg)
    p.should == "/pictures/3/show/100x33/crop/0x0/900x300/kitten.jpg"
  end

  it "should generate a url string for cropped thumbnail" do
    p = thumbnail_path(:id => 3, :crop => "crop", :size => "100x33", :name => "kitten", :format => :jpg)
    p.should == "/pictures/3/thumbnails/100x33/crop/kitten.jpg"
  end

  it "should generate a url string for thumbnail with default name and format" do
    p = thumbnail_path(:id => 3, :size => "100x33")
    p.should == "/pictures/3/thumbnails/100x33/thumbnail.png"
  end

  it "should generate a url string for cropped and masked thumbnail" do
    p = thumbnail_path(:id => 3, :crop_from => "0x0", :crop_size => "900x300", :size => "100x33", :name => "kitten", :format => :jpg)
    p.should == "/pictures/3/thumbnails/100x33/0x0/900x300/kitten.jpg"
  end

  it "should generate a url string for zoomed image" do
    p = zoom_picture_path(:id => 3, :name => "kitten", :format => :jpg)
    p.should == "/pictures/3/zoom/kitten.jpg"
  end

end
