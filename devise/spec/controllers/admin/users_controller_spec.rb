require 'spec_helper'

module Alchemy
  describe Admin::UsersController do

      let(:admin) { FactoryGirl.build_stubbed(:admin_user) }

      before do
        controller.stub(:store_user_request_time)
        User.stub(:find).and_return(admin)
        admin.stub(:update_without_password).and_return(true)
        admin.stub(:update_attributes).and_return(true)
        sign_in(admin)
      end

      describe '#new' do
        render_views

        it "has send_credentials checkbox activated" do
          xhr :get, :new
          response.body.should match /<input checked=\"checked\".+name=\"user\[send_credentials\]\".+type=\"checkbox\"/
        end
      end

      describe '#edit' do
        render_views

        it "has send_credentials checkbox deactivated" do
          xhr :get, :edit, id: admin.id
          response.body.should match /<input name=\"user\[send_credentials\]\".+type=\"checkbox\"/
        end
      end

      describe '#create' do
        before { ActionMailer::Base.deliveries = [] }

        it "creates an user record" do
          post :create, user: FactoryGirl.attributes_for(:user).merge(send_credentials: '1')
          Alchemy::User.count.should == 1
        end

        context "with send_credentials set to '1'" do
          it "should send an email notification" do
            post :create, user: FactoryGirl.attributes_for(:user).merge(send_credentials: '1')
            ActionMailer::Base.deliveries.should_not be_empty
          end
        end

        context "with send_credentials set to true" do
          it "should not send an email notification" do
            post :create, user: FactoryGirl.attributes_for(:user).merge(send_credentials: true)
            ActionMailer::Base.deliveries.should be_empty
          end
        end

        context "with send_credentials left blank" do
          it "should not send an email notification" do
            post :create, user: FactoryGirl.attributes_for(:user)
            ActionMailer::Base.deliveries.should be_empty
          end
        end
      end

      describe '#update' do
        before do
          ActionMailer::Base.deliveries = []
        end

        it "assigns user to @user" do
          post :update, id: admin.id, user: {email: admin.email}, format: :js
          assigns(:user).should eq(admin)
        end

        context "with empty password passed" do
          it "should update the user" do
            params_hash = {'firstname' => 'Johnny', 'password' => '', 'password_confirmation' => ''}
            admin.should_receive(:update_without_password).with(params_hash).and_return(true)
            post :update, id: admin.id, user: params_hash, format: :js
          end
        end

        context "with new password passed" do
          it "should update the user" do
            params_hash = {'firstname' => 'Johnny', 'password' => 'newpassword', 'password_confirmation' => 'newpassword'}
            admin.should_receive(:update_attributes).with(params_hash)
            post :update, id: admin.id, user: params_hash, format: :js
          end
        end

        context "with send_credentials set to '1'" do
          let(:user) { FactoryGirl.build(:user) }
          before { User.stub(:find).and_return(user) }

          it "should send an email notification" do
            post :update, id: user.id, user: {send_credentials: '1'}
            ActionMailer::Base.deliveries.should_not be_empty
          end
        end

        context "with send_credentials left blank" do
          it "should not send an email notification" do
            post :update, id: admin.id, user: {email: admin.login}, format: :js
            ActionMailer::Base.deliveries.should be_empty
          end
        end

        context "if user is permitted to update roles" do
          before do
            controller.stub(:can?).with(:update_role, Alchemy::User).and_return(true)
          end

          it "updates the user including role" do
            admin.should_receive(:update_without_password).with({'roles' => ['Administrator']})
            post :update, id: admin.id, user: {roles: ['Administrator']}, format: :js
          end
        end

        context "if the user is not permitted to update roles" do
          before do
            controller.stub(:can?).with(:update_role, Alchemy::User).and_return(false)
          end

          it "updates user without role" do
            admin.should_receive(:update_without_password).with({})
            post :update, id: admin.id, user: {roles: ['Administrator']}, format: :js
          end
        end

      end

  end
end
