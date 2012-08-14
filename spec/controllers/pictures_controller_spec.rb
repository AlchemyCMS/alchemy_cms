require 'spec_helper'

# Fixes missing method tempfile error
class Rack::Test::UploadedFile
  attr_reader :tempfile
end

module Alchemy
  describe PicturesController do

    let(:page)       { FactoryGirl.create(:public_page, :restricted => true) }
    let(:element)    { FactoryGirl.create(:element, :page => page, :name => 'bild') }
    let(:picture)    { Picture.create(:image_file => fixture_file_upload(File.expand_path('../../support/image.png', __FILE__), 'image/png')) }

    before do
      essence = element.contents.where(:name => 'image').first.essence
      essence.picture_id = picture.id
      essence.save
    end

    it "should not be possible to see pictures from restricted pages" do
      get :show, :id => picture.id
      response.status.should == 302
      response.should redirect_to(login_path)
    end

    context "as registered user" do

      before do
        activate_authlogic
        UserSession.create(FactoryGirl.create(:registered_user))
      end

      it "should be possible to see pictures from restricted pages" do
        get :show, :id => picture.id, :format => :png
        response.status.should == 200
      end

    end

  end
end
