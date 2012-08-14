require 'spec_helper'

module Alchemy
  describe ElementsController do

    let(:page)       { FactoryGirl.create(:public_page, :restricted => true) }
    let(:element)    { FactoryGirl.create(:element, :page => page, :name => 'download') }

    it "should not be possible to see restricted elements" do
      get :show, :id => element.id
      response.status.should == 302
      response.should redirect_to(login_path)
    end

    context "as a registered user" do

      before do
        activate_authlogic
        UserSession.create(FactoryGirl.create(:registered_user))
      end

      it "should be possible to see restricted elements" do
        get :show, :id => element.id
        response.status.should == 200
      end

    end

  end
end
