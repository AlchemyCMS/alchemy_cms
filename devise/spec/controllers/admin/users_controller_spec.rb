require 'spec_helper'

module Alchemy
  describe Admin::UsersController do
    let(:admin) { build_stubbed(:alchemy_admin_user) }
    let(:user)  { build_stubbed(:alchemy_user) }

    before do
      allow(controller).to receive_messages(store_user_request_time: true)
      allow(User).to receive(:find).and_return(user)
      authorize_user(admin)
    end

    describe '#index' do
      let(:user) { create :alchemy_user}

      context 'with matching search query' do
        it "lists all matching users" do
          alchemy_get :index, q: { email_cont: user.email }
          expect(assigns(:users)).to include(user)
        end
      end

      context 'with non-matching search query' do
        it "lists all matching users" do
          alchemy_get :index, q: { email_cont: "Tarzan" }
          expect(assigns(:users)).not_to include(user)
        end
      end

      context 'without search query' do
        it "lists all users" do
          alchemy_get :index
          expect(assigns(:users)).to include(user)
        end
      end
    end

    describe '#signup' do
      context "with users present" do
        before { allow(User).to receive_messages(count: 1) }

        it "redirects to admin dashboard" do
          alchemy_get :signup
          expect(response).to redirect_to(admin_dashboard_path)
        end
      end
    end

    describe '#create' do
      before { ActionMailer::Base.deliveries.clear }

      around do |example|
        perform_enqueued_jobs { example.run }
      end

      it "creates an user record" do
        alchemy_post :create, user: attributes_for(:alchemy_user)
        expect(Alchemy::User.count).to eq(1)
      end

      context 'while signup' do
        before { allow(User).to receive(:count).and_return(0) }

        it "sets the user role to admin." do
          alchemy_post :create, user: attributes_for(:alchemy_admin_user)
          expect(assigns(:user).alchemy_roles).to include("admin")
        end

        context "with valid params" do
          it "signs the user in." do
            expect(controller).to receive(:sign_in)
            alchemy_post :create, user: attributes_for(:alchemy_admin_user)
          end
        end
      end

      context "with send_credentials set to '1'" do
        it "should send an email notification" do
          alchemy_post :create, user: attributes_for(:alchemy_user).merge(send_credentials: '1')
          expect(ActionMailer::Base.deliveries).not_to be_empty
        end

        context 'with invalid user' do
          it "does not send an email notification" do
            alchemy_post :create, user: {send_credentials: '1', email: ''}
            expect(ActionMailer::Base.deliveries).to be_empty
          end
        end
      end

      context "with send_credentials set to true" do
        it "should not send an email notification" do
          alchemy_post :create, user: attributes_for(:alchemy_user).merge(send_credentials: true)
          expect(ActionMailer::Base.deliveries).to be_empty
        end
      end

      context "with send_credentials left blank" do
        it "should not send an email notification" do
          alchemy_post :create, user: attributes_for(:alchemy_user)
          expect(ActionMailer::Base.deliveries).to be_empty
        end
      end
    end

    describe '#update' do
      before { ActionMailer::Base.deliveries.clear }

      around do |example|
        perform_enqueued_jobs { example.run }
      end

      context "with empty password passed" do
        it "should update the user" do
          params_hash = {
            'firstname' => 'Johnny',
            'password' => '',
            'password_confirmation' => ''
          }
          expect(user)
            .to receive(:update_without_password)
            .with(params_hash).and_return(true)

          alchemy_post :update, id: user.id, user: params_hash, format: :js
        end
      end

      context "with new password passed" do
        it "should update the user" do
          params_hash = {
            'firstname' => 'Johnny',
            'password' => 'newpassword',
            'password_confirmation' => 'newpassword'
          }
          expect(user).to receive(:update).with(params_hash)

          alchemy_post :update, id: user.id, user: params_hash, format: :js
        end
      end

      context "with send_credentials set to '1'" do
        let(:user) { create(:alchemy_admin_user) }

        it "should send an email notification" do
          alchemy_post :update, id: user.id, user: {send_credentials: '1'}
          expect(ActionMailer::Base.deliveries).to_not be_empty
        end

        context 'with invalid user' do
          it "does not send an email notification" do
            alchemy_post :update, id: user.id, user: {send_credentials: '1', email: ''}
            expect(ActionMailer::Base.deliveries).to be_empty
          end
        end
      end

      context "with send_credentials left blank" do
        let(:user) { create(:alchemy_admin_user) }

        it "should not send an email notification" do
          alchemy_post :update, id: user.id, user: {email: user.email}
          expect(ActionMailer::Base.deliveries).to be_empty
        end
      end

      context "if user is permitted to update roles" do
        before do
          allow(controller)
            .to receive(:can?)
            .with(:update_role, Alchemy::User)
            .and_return(true)
        end

        it "updates the user including role" do
          expect(user)
            .to receive(:update_without_password)
            .with({'alchemy_roles' => ['Administrator']})
          alchemy_post :update, id: user.id, user: {alchemy_roles: ['Administrator']}, format: :js
        end
      end

      context "if the user is not permitted to update roles" do
        before do
          allow(controller)
            .to receive(:can?)
            .with(:update_role, Alchemy::User)
            .and_return(false)
        end

        it "updates user without role" do
          expect(user).to receive(:update_without_password).with({})
          alchemy_post :update, id: user.id, user: {alchemy_roles: ['Administrator']}, format: :js
        end
      end
    end

    describe '#destroy' do
      it "redirects to users list" do
        expect(user).to receive(:destroy).and_return(true)
        alchemy_delete :destroy, id: user.id
        expect(response).to redirect_to(admin_users_path)
      end
    end
  end
end
