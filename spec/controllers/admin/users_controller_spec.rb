require 'spec_helper'

describe Alchemy::Admin::UsersController do

  describe "POST update" do

    let!(:user) { FactoryGirl.create(:admin_user) }

    before do
      activate_authlogic
      Alchemy::UserSession.create user
    end

    it "assigns user to @user" do
      post :update, :id => user.id, :user => {}, :format => :js
      assigns(:user).should eq(user)
    end

    context "if user is permitted to update roles" do
      it "updates the user including role" do
        controller.stub(:permitted_to?).with(:update_role).and_return { true }
        Alchemy::User.any_instance.should_receive(:update_attributes).with({'role' => 'Administrator'})
        post :update, :id => user.id, :user => {:role => 'Administrator'}, :format => :js
      end
    end

    context "if the user is not permitted to update roles" do
      it "updates user without role" do
        controller.stub(:permitted_to?).with(:update_role).and_return { false }
        Alchemy::User.any_instance.should_receive(:update_attributes).with({})
        post :update, :id => user.id, :user => {'role' => 'Administrator'}, :format => :js
      end
    end

  end
end
