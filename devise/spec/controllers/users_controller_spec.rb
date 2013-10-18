require 'spec_helper'

module Alchemy
  describe UsersController do

    context "with users present" do
      before { build_stubbed(:admin_user) }

      it "should redirect to admin dashboard" do
        get :new
        response.should redirect_to(admin_dashboard_path)
      end
    end

    describe '#new' do
      render_views

      before { get :new }

      it "should not render tag list input" do
        response.body.should_not have_selector('.autocomplete_tag_list')
      end
    end

    describe '#create' do
      before { ActionMailer::Base.deliveries = [] }

      it "should set the role to admin" do
        post :create, {:user => FactoryGirl.attributes_for(:admin_user)}
        assigns(:user).roles.should include("admin")
      end

      context "with send_credentials set to '1'" do
        it "should send an email notification" do
          post :create, {
            :user => FactoryGirl.attributes_for(:admin_user).merge(send_credentials: '1')
          }
          ActionMailer::Base.deliveries.should_not be_empty
        end
      end

      context "with send_credentials left blank" do
        it "should not send an email notification" do
          post :create, {
            :user => FactoryGirl.attributes_for(:admin_user)
          }
          ActionMailer::Base.deliveries.should be_empty
        end
      end

      context "with valid params" do
        it "should sign in the user" do
          post :create, {
            :user => FactoryGirl.attributes_for(:admin_user)
          }
          controller.send(:user_signed_in?).should be_true
        end
      end

    end

  end
end
