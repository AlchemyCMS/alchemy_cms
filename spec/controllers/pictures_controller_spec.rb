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
        get :show, :id => picture.id, :format => :png
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
          get :show, :id => picture.id, :format => :png
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
          get :show, :id => picture.id
          response.status.should == 302
          response.should redirect_to(login_path)
        end

      end

      context "as registered user" do

        before do
          activate_authlogic
          UserSession.create(FactoryGirl.create(:registered_user))
        end

        it "should render the picture" do
          get :show, :id => picture.id, :format => :png
          response.status.should == 200
        end

      end


    end


  end
end
