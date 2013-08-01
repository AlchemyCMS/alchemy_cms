require 'spec_helper'

module Alchemy
  describe AttachmentsController do
    let(:attachment) { build_stubbed(:attachment) }

    before {
      attachment.stub(:restricted?).and_return(true)
      Attachment.stub(:find).and_return(attachment)
    }

    it "should not be possible to download attachments from restricted pages" do
      get :download, :id => attachment.id
      response.status.should == 302
      response.should redirect_to(login_path)
    end

    it "should not be possible to see attachments from restricted pages" do
      get :show, :id => attachment.id
      response.status.should == 302
      response.should redirect_to(login_path)
    end

    context "as member user" do
      before {
        sign_in(member_user)
      }

      it "should be possible to download attachments from restricted pages" do
        get :download, :id => attachment.id
        response.status.should == 200
      end

      it "should be possible to see attachments from restricted pages" do
        get :show, :id => attachment.id
        response.status.should == 200
      end
    end
  end
end
