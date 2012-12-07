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

    it "is not valid without image file" do
      picture = Picture.new
      picture.should_not be_valid
    end

    describe '#suffix' do

      it "should return the suffix of original filename" do
        pic = stub_model(Picture, :image_file_name => 'kitten.JPG')
        pic.stub(:image_file).and_return(OpenStruct.new({:ext => 'jpg'}))
        pic.suffix.should == "jpg"
      end

      context "image has no suffix" do
        it "should return empty string" do
          pic = stub_model(Picture, :image_file_name => 'kitten')
          pic.stub(:image_file).and_return(OpenStruct.new({:ext => ''}))
          pic.suffix.should == ""
        end
      end

    end

    describe '#humanized_name' do

      it "should return a humanized version of original filename" do
        pic = stub_model(Picture, :image_file_name => 'cute_kitten.JPG')
        pic.stub(:image_file).and_return(OpenStruct.new({:ext => 'jpg'}))
        pic.humanized_name.should == "Cute kitten"
      end

      it "should not remove incidents of suffix from filename" do
        pic = stub_model(Picture, :image_file_name => 'cute_kitten_mo.jpgi.JPG')
        pic.stub(:image_file).and_return(OpenStruct.new({:ext => 'jpg'}))
        pic.humanized_name.should == "Cute kitten mo.jpgi"
        pic.humanized_name.should_not == "Cute kitten moi"
      end

      context "image has no suffix" do
        it "should return humanized name" do
          pic = stub_model(Picture, :image_file_name => 'cute_kitten')
          pic.stub(:suffix).and_return("")
          pic.humanized_name.should == "Cute kitten"
        end
      end

    end

    describe '#security_token' do

      before do
        @pic = stub_model(Picture, :id => 1)
      end

      it "should return a sha1 hash" do
        @pic.security_token.should match(/\b([a-f0-9]{16})\b/)
      end

      it "should return a 16 chars long hash" do
        @pic.security_token.length == 16
      end

      it "should convert crop true value into string" do
        digest = PictureAttributes.secure({:id => @pic.id, :crop => 'crop'})
        @pic.security_token(:crop => true).should == digest
      end

      it "should always include picture id" do
        digest = PictureAttributes.secure({:id => @pic.id})
        @pic.security_token.should == digest
      end

    end

    describe '.last_upload' do

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

    describe '.recent' do

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

    describe '#destroy' do
      context "a picture that is assigned in an essence" do

        let(:essence_picture) { EssencePicture.create }
        let(:picture) { FactoryGirl.create :picture }
        before { essence_picture.update_attributes(:picture_id => picture.id) }

        it "should raise error message" do
          expect { picture.destroy }.to raise_error PictureInUseError
        end

      end
    end

  end
end
