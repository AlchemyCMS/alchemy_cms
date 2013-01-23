require 'spec_helper'

# Fixes missing method tempfile error
class Rack::Test::UploadedFile
  attr_reader :tempfile
end

module Alchemy
  describe AttachmentsController do

    let(:page)       { FactoryGirl.create(:public_page, :restricted => true) }
    let(:element)    { FactoryGirl.create(:element, :page => page, :name => 'download', :create_contents_after_create => true) }
    let(:attachment) { Attachment.create(:uploaded_data => fixture_file_upload(File.expand_path('../../support/image.png', __FILE__), 'image/png')) }

    before do
      essence = element.contents.where(:name => 'file').first.essence
      essence.attachment_id = attachment.id
      essence.save
    end

    it "should not be possible to download attachments from restricted pages" do
      get :download, :id => attachment.id
      response.status.should == 302
      response.should redirect_to(login_path)
    end

    context "as registered user" do

      before do
        sign_in :user, FactoryGirl.create(:registered_user)
      end

      it "should be possible to download attachments from restricted pages" do
        get :download, :id => attachment.id
        response.status.should == 200
      end

    end

    it "should not be possible to see attachments from restricted pages" do
      get :show, :id => attachment.id
      response.status.should == 302
      response.should redirect_to(login_path)
    end

    context "as registered user" do

      before do
        sign_in :user, FactoryGirl.create(:registered_user)
      end

      it "should be possible to see attachments from restricted pages" do
        get :show, :id => attachment.id
        response.status.should == 200
      end

    end

  end
end
