require 'spec_helper'

module Alchemy
  describe Admin::UsersController do
      let(:admin) { build_stubbed(:alchemy_admin_user) }
      let(:user)  { build_stubbed(:alchemy_user) }

      before do
        allow(controller).to receive_messages(store_user_request_time: true)
        allow(User).to receive(:find).and_return(user)
        allow(user).to receive(:update_without_password).and_return(true)
        allow(user).to receive(:update_attributes).and_return(true)
        sign_in(admin)
      end

      describe '#index' do
        let(:users) { [] }

        before do
          allow(users)
            .to receive_message_chain(:page, :per, :order)
            .and_return([user])
        end

        context 'with search query' do
          it "lists all matching users" do
            expect(User).to receive(:search).and_return(users)
            get :index, query: user.email
            expect(assigns(:users)).to include(user)
          end
        end

        context 'without search query' do
          it "lists all users" do
            expect(User).to receive(:all).and_return(users)
            get :index
            expect(assigns(:users)).to include(user)
          end
        end
      end

      describe '#new' do
        render_views

        it "has send_credentials checkbox activated" do
          get :new
          expect(response.body).to match /<input checked=\"checked\".+name=\"user\[send_credentials\]\".+type=\"checkbox\"/
        end
      end

      describe '#edit' do
        render_views

        it "has send_credentials checkbox deactivated" do
          xhr :get, :edit, id: admin.id
          expect(response.body).to match /<input name=\"user\[send_credentials\]\".+type=\"checkbox\"/
        end
      end

      describe '#create' do
        before { ActionMailer::Base.deliveries = [] }

        it "creates an user record" do
          post :create, user: FactoryGirl.attributes_for(:alchemy_user).merge(send_credentials: '1')
          expect(Alchemy::User.count).to eq(1)
        end

        context "with send_credentials set to '1'" do
          it "should send an email notification" do
            post :create, user: FactoryGirl.attributes_for(:alchemy_user).merge(send_credentials: '1')
            expect(ActionMailer::Base.deliveries).not_to be_empty
          end
        end

        context "with send_credentials set to true" do
          it "should not send an email notification" do
            post :create, user: FactoryGirl.attributes_for(:alchemy_user).merge(send_credentials: true)
            expect(ActionMailer::Base.deliveries).to be_empty
          end
        end

        context "with send_credentials left blank" do
          it "should not send an email notification" do
            post :create, user: FactoryGirl.attributes_for(:alchemy_user)
            expect(ActionMailer::Base.deliveries).to be_empty
          end
        end
      end

      describe '#update' do
        before do
          ActionMailer::Base.deliveries = []
        end

        it "assigns user to @user" do
          post :update, id: user.id, user: {email: user.email}, format: :js
          expect(assigns(:user)).to eq(user)
        end

        context "with empty password passed" do
          it "should update the user" do
            params_hash = {'firstname' => 'Johnny', 'password' => '', 'password_confirmation' => ''}
            expect(user).to receive(:update_without_password).with(params_hash).and_return(true)
            post :update, id: user.id, user: params_hash, format: :js
          end
        end

        context "with new password passed" do
          it "should update the user" do
            params_hash = {'firstname' => 'Johnny', 'password' => 'newpassword', 'password_confirmation' => 'newpassword'}
            expect(user).to receive(:update_attributes).with(params_hash)
            post :update, id: user.id, user: params_hash, format: :js
          end
        end

        context "with send_credentials set to '1'" do
          it "should send an email notification" do
            expect(user).to receive(:update_without_password).with('send_credentials' => '1')
            post :update, id: user.id, user: {send_credentials: '1'}
          end
        end

        context "with send_credentials left blank" do
          it "should not send an email notification" do
            expect(user).to receive(:update_without_password).with('email' => user.email)
            post :update, id: user.id, user: {email: user.email}
          end
        end

        context "if user is permitted to update roles" do
          before do
            allow(controller).to receive(:can?).with(:update_role, Alchemy::User).and_return(true)
          end

          it "updates the user including role" do
            expect(user).to receive(:update_without_password).with({'alchemy_roles' => ['Administrator']})
            post :update, id: user.id, user: {alchemy_roles: ['Administrator']}, format: :js
          end
        end

        context "if the user is not permitted to update roles" do
          before do
            allow(controller).to receive(:can?).with(:update_role, Alchemy::User).and_return(false)
          end

          it "updates user without role" do
            expect(user).to receive(:update_without_password).with({})
            post :update, id: user.id, user: {alchemy_roles: ['Administrator']}, format: :js
          end
        end
      end

      describe '#destroy' do
        it "redirects to users list" do
          expect(user).to receive(:destroy).and_return(true)
          delete :destroy, id: user.id
          expect(response).to redirect_to(admin_users_path)
        end
      end

  end
end
