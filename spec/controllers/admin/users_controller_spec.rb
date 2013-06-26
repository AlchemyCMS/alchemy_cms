require 'spec_helper'

describe Alchemy::Admin::UsersController do
  let(:admin) { FactoryGirl.create(:admin_user, email: 'admin@admin.com', login: 'admin') }
  before { sign_in :user, admin }

  describe '#new' do
    render_views

    it "has send_credentials checkbox activated" do
      get :new
      response.body.should match /<input checked="checked" id="user_send_credentials" name="user\[send_credentials\]" type="checkbox"/
    end
  end

  describe '#edit' do
    render_views

    it "has send_credentials checkbox deactivated" do
      get :edit, id: admin.id
      response.body.should match /<input id="user_send_credentials" name="user\[send_credentials\]" type="checkbox"/
    end
  end

  describe '#create' do
    before { ActionMailer::Base.deliveries = [] }

    it "creates an user record" do
      post :create, user: FactoryGirl.attributes_for(:user).merge(send_credentials: true)
      Alchemy::User.count.should == 2
    end

    context "with send_credentials set to true" do
      it "should send an email notification" do
        post :create, user: FactoryGirl.attributes_for(:user).merge(send_credentials: true)
        ActionMailer::Base.deliveries.should_not be_empty
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
    let(:user) { FactoryGirl.create(:user) }

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
        post :update, id: user.id, user: {send_credentials: true}
        ActionMailer::Base.deliveries.should_not be_empty
      end
    end

    context "with send_credentials left blank" do
      it "should not send an email notification" do
        post :update, :id => user.id, :user => {}
        ActionMailer::Base.deliveries.should be_empty
      end
    end

    context "if user is permitted to update roles" do
      it "updates the user including role" do
        controller.stub(:permitted_to?).with(:update_roles).and_return { true }
        Alchemy::User.any_instance.should_receive(:update_attributes).with({'roles' => ['Administrator']})
        post :update, :id => user.id, :user => {:roles => ['Administrator']}, :format => :js
      end
    end

    context "if the user is not permitted to update roles" do
      it "updates user without role" do
        controller.stub(:permitted_to?).with(:update_roles).and_return { false }
        Alchemy::User.any_instance.should_receive(:update_attributes).with({})
        post :update, :id => user.id, :user => {'roles' => ['Administrator']}, :format => :js
      end
    end
  end

end
