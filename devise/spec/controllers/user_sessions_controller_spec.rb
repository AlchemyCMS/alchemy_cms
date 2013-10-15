require 'spec_helper'

module Alchemy
  describe UserSessionsController do

    let(:user) { FactoryGirl.build_stubbed(:admin_user) }

    before do
      controller.stub(:store_user_request_time)
      sign_in(user)
    end

    describe "#destroy" do
      it "should unlock all pages" do
        @request.env["devise.mapping"] = Devise.mappings[:user]
        user.should_receive(:unlock_pages!)
        delete :destroy
      end
    end

  end
end
