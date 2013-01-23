require 'spec_helper'

module Alchemy
  describe UserSessionsController do

    let(:user) { FactoryGirl.create(:admin_user) }
    let(:page) { FactoryGirl.create(:page) }

    before { sign_in :user, user }

    describe "signout" do
      it "should unlock all pages" do
        @request.env["devise.mapping"] = Devise.mappings[:user]
        page.lock(user)
        delete :destroy
        user.locked_pages.should be_empty
      end
    end

  end
end
