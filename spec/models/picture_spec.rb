require 'spec_helper'

describe Alchemy::Picture do

  it "is valid with valid attributes" do
    picture = Alchemy::Picture.new(:image_file => File.new(File.expand_path('../support/image.png', __FILE__)))
    picture.should be_valid
  end

  describe '#suffix' do

    it "should return the suffix of original filename" do
      pic = stub_model(Alchemy::Picture, :image_filename => 'kitten.JPG')
      pic.suffix.should == "jpg"
    end

    context "image has no suffix" do

      before(:each) do
        @pic = stub_model(Alchemy::Picture, :image_filename => 'kitten')
      end

      it "should return empty string" do
        @pic.suffix.should == ""
      end

    end

  end

  describe '#humanized_name' do

    it "should return a humanized version of original filename" do
      pic = stub_model(Alchemy::Picture, :image_filename => 'cute_kitten.JPG')
      pic.humanized_name.should == "Cute kitten"
    end

    it "should not remove incidents of suffix from filename" do
      pic = stub_model(Alchemy::Picture, :image_filename => 'cute_kitten_mo.jpgi.JPG')
      pic.humanized_name.should == "Cute kitten mo.jpgi"
      pic.humanized_name.should_not == "Cute kitten moi"
    end

    context "image has no suffix" do

      before(:each) do
        @pic = stub_model(Alchemy::Picture, :image_filename => 'cute_kitten')
        @pic.stub!(:suffix).and_return("")
      end

      it "should return humanized name" do
        @pic.humanized_name.should == "Cute kitten"
      end

    end

  end

  describe '#self.last_upload' do

    it "should return all pictures that have the same upload-hash as the most recent picture" do
      other_upload = Alchemy::Picture.create!(:image_file => File.open(File.expand_path('../support/image.png', __FILE__)), :upload_hash => '456')
      same_upload = Alchemy::Picture.create!(:image_file => File.open(File.expand_path('../support/image.png', __FILE__)), :upload_hash => '123')
      most_recent = Alchemy::Picture.create!(:image_file => File.open(File.expand_path('../support/image.png', __FILE__)), :upload_hash => '123')

      Alchemy::Picture.last_upload.should include(most_recent)
      Alchemy::Picture.last_upload.should include(same_upload)
      Alchemy::Picture.last_upload.should_not include(other_upload)

      [other_upload, same_upload, most_recent].each { |p| p.destroy }
    end

  end

  describe '#self.recent' do

    before(:all) do
      now = Time.now
      @recent = Alchemy::Picture.create!(:image_file => File.open(File.expand_path('../support/image.png', __FILE__)))
      @old_picture = Alchemy::Picture.create!(:image_file => File.open(File.expand_path('../support/image.png', __FILE__)))
      @recent.update_attribute(:created_at, now-23.hours)
      @old_picture.update_attribute(:created_at, now-10.days)
    end

    after(:all) { [recent, now].each { |p| p.destroy } }

    it "should return all pictures that have been created in the last 24 hours" do
      Alchemy::Picture.recent.should include(@recent)
    end

    it "should not return old pictures" do
      Alchemy::Picture.recent.should_not include(@old_picture)
    end

  end

end
