require 'spec_helper'

module Alchemy
  describe Admin::UsersController do

      let(:user) { FactoryGirl.build_stubbed(:admin_user) }

      before do
        controller.stub!(:store_user_request_time)
        User.stub!(:find).and_return(user)
        user.stub!(:update_without_password).and_return(true)
        user.stub!(:update_attributes).and_return(true)
        sign_in(user)
      end

      describe '#update' do
        before do
          ActionMailer::Base.deliveries = []
        end

        it "assigns user to @user" do
          post :update, id: user.id, user: {}, format: :js
          assigns(:user).should eq(user)
        end

        context "with empty password passed" do
          it "should update the user" do
            params_hash = {'firstname' => 'Johnny', 'password' => '', 'password_confirmation' => ''}
            user.should_receive(:update_without_password).with(params_hash).and_return(true)
            post :update, id: user.id, user: params_hash, format: :js
          end
        end

        context "with new password passed" do
          it "should update the user" do
            params_hash = {'firstname' => 'Johnny', 'password' => 'newpassword', 'password_confirmation' => 'newpassword'}
            user.should_receive(:update_attributes).with(params_hash)
            post :update, id: user.id, user: params_hash, format: :js
          end
        end

        context "with send_credentials set to true" do
          it "should send an email notification" do
            post :update, id: user.id, send_credentials: true, user: {}, format: :js
            ActionMailer::Base.deliveries.should_not be_empty
          end
        end

        context "with send_credentials left blank" do
          it "should not send an email notification" do
            post :update, id: user.id, user: {}, format: :js
            ActionMailer::Base.deliveries.should be_empty
          end
        end

        context "if user is permitted to update roles" do
          before do
            controller.stub!(:permitted_to?).with(:update_roles).and_return(true)
          end

          it "updates the user including role" do
            user.should_receive(:update_without_password).with({'roles' => ['Administrator']})
            post :update, id: user.id, user: {roles: ['Administrator']}, format: :js
          end
        end

        context "if the user is not permitted to update roles" do
          before do
            controller.stub!(:permitted_to?).with(:update_roles).and_return(false)
          end
          
          it "updates user without role" do
            user.should_receive(:update_without_password).with({})
            post :update, id: user.id, user: {'roles' => ['Administrator']}, format: :js
          end
        end
        
      end

  end
end
