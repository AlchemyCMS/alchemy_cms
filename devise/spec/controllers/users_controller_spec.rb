require 'spec_helper'

module Alchemy
  describe UsersController do

    context "with users present" do
      before { allow(User).to receive_messages(count: 1) }

      it "should redirect to admin dashboard" do
        get :new
        expect(response).to redirect_to(admin_dashboard_path)
      end
    end

    describe '#new' do
      render_views

      before { get :new }

      it "should not render tag list input" do
        expect(response.body).not_to have_selector('.autocomplete_tag_list')
      end
    end

    describe '#create' do
      before { ActionMailer::Base.deliveries = [] }

      it "should set the role to admin" do
        post :create, {user: attributes_for(:alchemy_admin_user)}
        expect(assigns(:user).alchemy_roles).to include("admin")
      end

      context "with send_credentials set to '1'" do
        it "should send an email notification" do
          post :create, {
            user: attributes_for(:alchemy_admin_user).merge(send_credentials: '1')
          }
          expect(ActionMailer::Base.deliveries).not_to be_empty
        end
      end

      context "with send_credentials left blank" do
        it "should not send an email notification" do
          post :create, {
            user: attributes_for(:alchemy_admin_user)
          }
          expect(ActionMailer::Base.deliveries).to be_empty
        end
      end

      context "with valid params" do
        it "should sign in the user" do
          post :create, {user: attributes_for(:alchemy_admin_user)}
          expect(controller.send(:user_signed_in?)).to be_truthy
        end
      end

      context "with invalid params" do
        it "renders the new view" do
          post :create, user: {email: '', login: '', password: ''}
          is_expected.to render_template(:new)
        end
      end

      context "with email delivery errors" do
        it "redirects to sitemap" do
          allow_any_instance_of(User).to receive(:save).and_raise(Errno::ECONNREFUSED)
          post :create, {user: attributes_for(:alchemy_admin_user)}
          is_expected.to redirect_to(admin_pages_path)
        end
      end
    end

  end
end
