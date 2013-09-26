# encoding: utf-8
require 'spec_helper'

module Alchemy
  describe Picture do

    let :image_file do
      File.new(File.expand_path('../../support/image.png', __FILE__))
    end

    let(:picture) { Picture.new }

    it "is valid with valid attributes" do
      picture = Picture.new(:image_file => image_file)
      picture.should be_valid
    end

    it "is not valid without image file" do
      picture = Picture.new
      picture.should_not be_valid
    end

    it "is valid with capitalized image file extension" do
      image_file = File.new(File.expand_path('../../support/image2.PNG', __FILE__))
      picture = Picture.new(:image_file => image_file)
      picture.should be_valid
    end

    it "is valid with jpeg image file extension" do
      image_file = File.new(File.expand_path('../../support/image3.jpeg', __FILE__))
      picture = Picture.new(:image_file => image_file)
      picture.should be_valid
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
        pic.humanized_name.should == "cute kitten"
      end

      it "should not remove incidents of suffix from filename" do
        pic = stub_model(Picture, :image_file_name => 'cute_kitten_mo.jpgi.JPG')
        pic.stub(:image_file).and_return(OpenStruct.new({:ext => 'jpg'}))
        pic.humanized_name.should == "cute kitten mo.jpgi"
        pic.humanized_name.should_not == "cute kitten moi"
      end

      context "image has no suffix" do
        it "should return humanized name" do
          pic = stub_model(Picture, :image_file_name => 'cute_kitten')
          pic.stub(:suffix).and_return("")
          pic.humanized_name.should == "cute kitten"
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

    describe '.filtered_by' do

      let :picture do
        FactoryGirl.build_stubbed(:picture)
      end

      context "with 'recent' as argument" do
        it 'should call the .recent scope' do
          Picture.should_receive(:recent).and_return(picture)
          Picture.filtered_by('recent').should eq(picture)
        end
      end

      context "with 'last_upload' as argument" do
        it 'should call the .last_upload scope' do
          Picture.should_receive(:last_upload).and_return(picture)
          Picture.filtered_by('last_upload').should eq(picture)
        end
      end

      context "with 'without_tag' as argument" do
        it 'should call the .without_tag scope' do
          Picture.should_receive(:without_tag).and_return(picture)
          Picture.filtered_by('without_tag').should eq(picture)
        end
      end

      context "with no argument" do
        it 'should return the scoped collection' do
          Picture.should_receive(:scoped).and_return(picture)
          Picture.filtered_by('').should eq(picture)
        end
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

      before do
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

    describe '#default_mask' do

      before do
        picture.stub!(:image_file_width).and_return(200)
        picture.stub!(:image_file_height).and_return(100)
      end

      it "should return a Hash" do
        expect(picture.default_mask('10x10')).to be_a(Hash)
      end

      context "cropping the picture to 200x50 pixel" do
        it "should contain the correct coordination values in the hash" do
          expect(picture.default_mask('200x50')).to eq({x1: 0, y1: 25, x2: 200, y2: 75})
        end
      end

      context "if picture´s cropping size is 0x0 pixel" do
        it "should not crop the picture" do
          expect(picture.default_mask('0x0')).to eq({x1: 0, y1: 0, x2: 200, y2: 100})
        end
      end

      context "cropping the picture to 50x100 pixel" do
        it "should contain the correct coordination values in the hash" do
          expect(picture.default_mask('50x100')).to eq({x1: 75, y1: 0, x2: 125, y2: 100})
        end
      end

    end
    
    describe "#cropped_thumbnail_size" do

      context "if given size is blank or 111x93" do
        it "should return the default size of '111x93'" do
          expect(picture.cropped_thumbnail_size('')).to eq('111x93')
          expect(picture.cropped_thumbnail_size('111x93')).to eq('111x93')
        end
      end

      context "if the given width is 400 and the height is 300 because of picture cropping" do
        it "should return the correct recalculated size value" do
          expect(picture.cropped_thumbnail_size('400x300')).to eq('111x83')
        end
      end

      context "if the given width is 300 and the height is 400 because of picture cropping" do
        it "should return the correct recalculated size value" do
          expect(picture.cropped_thumbnail_size('300x400')).to eq('70x93')
        end
      end
    end
    
    describe "#image_file_dimensions" do
      it "should return the width and height in the format of '1024x768'" do
        picture.image_file = image_file
        expect(picture.image_file_dimensions).to eq('1 x 1')
      end
    end

  end
end
