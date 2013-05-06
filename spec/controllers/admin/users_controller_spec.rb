require 'spec_helper'

describe Alchemy::Admin::UsersController do

  describe "POST update" do

    let!(:user) { FactoryGirl.create(:admin_user) }

    before do
      sign_in :user, user
    end

    describe '#update' do
      before { ActionMailer::Base.deliveries = [] }

      it "assigns user to @user" do
        post :update, :id => user.id, :user => {}, :format => :js
        assigns(:user).should eq(user)
      end

      context "with empty password passed" do
        it "should update the user" do
          post :update, :id => user.id, :user => {:firstname => 'Johnny', :password => '', :password_confirmation => ''}, :format => :js
          assigns(:user).should be_valid
        end
      end

      context "with new password passed" do
        it "should update the user" do
          post :update, :id => user.id, :user => {:firstname => 'Johnny', :password => 'newpassword', :password_confirmation => 'newpassword'}, :format => :js
          assigns(:user).password.should == 'newpassword'
        end
      end

      context "with send_credentials set to true" do
        it "should send an email notification" do
          post :update, :id => user.id, :send_credentials => true, :user => {}
          ActionMailer::Base.deliveries.should_not be_empty
        end
      end

      context "with send_credentials left blank" do
        it "should not send an email notification" do
          post :update, :id => user.id, :user => {}
          ActionMailer::Base.deliveries.should be_empty
        end
      end
    end

    context "if user is permitted to update roles" do
      it "updates the user including role" do
        controller.stub(:permitted_to?).with(:update_role).and_return { true }
        Alchemy::User.any_instance.should_receive(:update_attributes).with({'roles' => ['Administrator']})
        post :update, :id => user.id, :user => {:roles => ['Administrator']}, :format => :js
      end
    end

    context "if the user is not permitted to update roles" do
      it "updates user without role" do
        controller.stub(:permitted_to?).with(:update_role).and_return { false }
        Alchemy::User.any_instance.should_receive(:update_attributes).with({})
        post :update, :id => user.id, :user => {'roles' => ['Administrator']}, :format => :js
      end
    end

  end
end
