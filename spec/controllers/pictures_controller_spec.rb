require 'spec_helper'

# Fixes missing method tempfile error
class Rack::Test::UploadedFile
  attr_reader :tempfile
end

module Alchemy
  describe PicturesController do

    let(:page)               { FactoryGirl.create(:public_page, :restricted => false) }
    let(:restricted_page)    { FactoryGirl.create(:public_page, :restricted => true) }
    let(:element)            { FactoryGirl.create(:element, :page => page, :name => 'bild', :create_contents_after_create => true) }
    let(:restricted_element) { FactoryGirl.create(:element, :page => restricted_page, :name => 'bild', :create_contents_after_create => true) }
    let(:picture)            { Picture.create(:image_file => fixture_file_upload(File.expand_path('../../support/image.png', __FILE__), 'image/png')) }

    context "Requesting a picture that is not assigned with any page" do
      it "should render the picture" do
        get :show, :id => picture.id, :format => :png, :sh => picture.security_token
        response.status.should == 200
      end
    end

    context "Requesting a picture that is assigned on restricted and non-restricted pages" do
      before do
        essence = element.contents.where(:name => 'image').first.essence
        essence.picture_id = picture.id
        essence.save

        essence = restricted_element.contents.where(:name => 'image').first.essence
        essence.picture_id = picture.id
        essence.save
      end

      context "as guest user" do
        it "should render the picture" do
          get :show, :id => picture.id, :format => :png, :sh => picture.security_token
          response.status.should == 200
        end
      end
    end

    context "Requesting a picture that is assigned with restricted pages only" do
      before do
        essence = restricted_element.contents.where(:name => 'image').first.essence
        essence.picture_id = picture.id
        essence.save
      end

      context "as guest user" do
        it "should not render the picture, but redirect to login path" do
          get :show, :id => picture.id, :sh => picture.security_token
          response.status.should == 302
          response.should redirect_to(login_path)
        end
      end

      context "as registered user" do
        before do
          sign_in :user, FactoryGirl.create(:registered_user)
        end

        it "should render the picture" do
          get :show, :id => picture.id, :format => :png, :sh => picture.security_token
          response.status.should == 200
        end
      end
    end

    describe 'Picture processing' do

      context "with crop and size parameters" do

        let(:big_picture) { Picture.create(:image_file => fixture_file_upload(File.expand_path('../../support/80x60.png', __FILE__), 'image/png')) }

        it "should return a cropped image." do
          options = {
            :crop => 'crop',
            :size => '10x10',
            :format => 'png'
          }
          get :show, options.merge(:id => big_picture.id, :sh => big_picture.security_token(options))
          response.body[0x10..0x18].unpack('NN').should == [10,10]
        end

        context "without upsample parameter" do
          it "should not upsample the image." do
            options = {
              :crop => 'crop',
              :size => '10x10',
              :format => 'png'
            }
            get :show, options.merge(:id => picture.id, :sh => picture.security_token(options))
            response.body[0x10..0x18].unpack('NN').should == [1,1]
          end
        end

        context "and with upsample true" do
          it "should return an upsampled image." do
            options = {
              :crop => 'crop',
              :size => '10x10',
              :upsample => 'true',
              :format => 'png'
            }
            get :show, options.merge(:id => picture.id, :sh => picture.security_token(options))
            response.body[0x10..0x18].unpack('NN').should == [10,10]
          end
        end

      end

    end

  end
end
