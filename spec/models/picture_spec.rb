require 'spec_helper'

module Alchemy
  describe Picture do

    let :image_file do
      File.new(File.expand_path('../../support/image.png', __FILE__))
    end

    it "is valid with valid attributes" do
      picture = Picture.new(:image_file => image_file)
      picture.should be_valid
    end

    describe '#suffix' do

      it "should return the suffix of original filename" do
        pic = stub_model(Picture, :image_filename => 'kitten.JPG')
        pic.suffix.should == "jpg"
      end

      context "image has no suffix" do

        before(:each) do
          @pic = stub_model(Picture, :image_filename => 'kitten')
        end

        it "should return empty string" do
          @pic.suffix.should == ""
        end

      end

    end

    describe '#humanized_name' do

      it "should return a humanized version of original filename" do
        pic = stub_model(Picture, :image_filename => 'cute_kitten.JPG')
        pic.humanized_name.should == "Cute kitten"
      end

      it "should not remove incidents of suffix from filename" do
        pic = stub_model(Picture, :image_filename => 'cute_kitten_mo.jpgi.JPG')
        pic.humanized_name.should == "Cute kitten mo.jpgi"
        pic.humanized_name.should_not == "Cute kitten moi"
      end

      context "image has no suffix" do

        before(:each) do
          @pic = stub_model(Picture, :image_filename => 'cute_kitten')
          @pic.stub!(:suffix).and_return("")
        end

        it "should return humanized name" do
          @pic.humanized_name.should == "Cute kitten"
        end

      end

    end

    describe '#self.last_upload' do

      it "should return all pictures that have the same upload-hash as the most recent picture" do
        other_upload = Picture.create!(:image_file => image_file, :upload_hash => '456')
        same_upload = Picture.create!(:image_file => image_file, :upload_hash => '123')
        most_recent = Picture.create!(:image_file => image_file, :upload_hash => '123')

        Picture.last_upload.should include(most_recent)
        Picture.last_upload.should include(same_upload)
        Picture.last_upload.should_not include(other_upload)

        [other_upload, same_upload, most_recent].each { |p| p.destroy }
      end

    end

    describe '#self.recent' do

      before(:all) do
        now = Time.now
        @recent = Picture.create!(:image_file => image_file)
        @old_picture = Picture.create!(:image_file => image_file)
        @recent.update_column(:created_at, now-23.hours)
        @old_picture.update_column(:created_at, now-10.days)
      end

      it "should return all pictures that have been created in the last 24 hours" do
        Picture.recent.should include(@recent)
      end

      it "should not return old pictures" do
        Picture.recent.should_not include(@old_picture)
      end

    end

  end
end
