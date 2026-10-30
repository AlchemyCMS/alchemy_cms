# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::UserImpersonationsController do
  routes { Alchemy::Engine.routes }

  let(:admin) { create(:alchemy_admin_user) }
  let(:member) { create(:alchemy_member_user) }

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    allow(controller).to receive(:store_user_request_time)
    sign_in admin
    stub_config(Alchemy::Devise.config, user_impersonation: true)
  end

  describe "POST #create" do
    it "stores the administrator, switches the Warden user, and redirects to the frontend" do
      post :create, params: {user_id: member.id}

      expect(session[:alchemy_devise_original_user_id]).to eq(admin.id)
      expect(response).to redirect_to("/")
    end

    it "does not change the target password" do
      password_digest = member.encrypted_password

      post :create, params: {user_id: member.id}

      expect(member.reload.encrypted_password).to eq(password_digest)
    end

    it "makes the target the effective Devise user" do
      post :create, params: {user_id: member.id}

      expect(controller.warden.user(:user)).to eq(member)
    end

    it "uses the configured relative frontend path" do
      stub_config(Alchemy::Devise.config, user_impersonation_redirect_path: "/account")

      post :create, params: {user_id: member.id}

      expect(response).to redirect_to("/account")
    end

    it "does not redirect to another host" do
      stub_config(Alchemy::Devise.config, user_impersonation_redirect_path: "https://example.com")

      post :create, params: {user_id: member.id}

      expect(response).to redirect_to("/")
    end

    it "denies direct access when disabled" do
      stub_config(Alchemy::Devise.config, user_impersonation: false)

      post :create, params: {user_id: member.id}

      expect(response).to redirect_to(admin_dashboard_path)
      expect(session[:alchemy_devise_original_user_id]).to be_nil
    end

    it "denies nested impersonation without overwriting the administrator" do
      session[:alchemy_devise_original_user_id] = admin.id

      post :create, params: {user_id: member.id}

      expect(response).to redirect_to(admin_dashboard_path)
      expect(session[:alchemy_devise_original_user_id]).to eq(admin.id)
    end

    it "handles a missing target safely" do
      expect { post :create, params: {user_id: "missing"} }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "DELETE #destroy" do
    before do
      session[:alchemy_devise_original_user_id] = admin.id
      sign_in member
    end

    it "restores the administrator, clears state, and redirects to users" do
      delete :destroy

      expect(session[:alchemy_devise_original_user_id]).to be_nil
      expect(response).to redirect_to(admin_users_path)
    end

    it "makes the administrator the effective Devise user again" do
      delete :destroy

      expect(controller.warden.user(:user)).to eq(admin)
    end

    it "signs out and clears state when the administrator is missing" do
      admin.destroy!
      expect(controller.warden).to receive(:logout).with(:user)

      delete :destroy

      expect(session[:alchemy_devise_original_user_id]).to be_nil
      expect(response).to redirect_to(Alchemy.config.login_path)
    end

    it "does not restore an inactive administrator" do
      allow_any_instance_of(Alchemy::User).to receive(:active_for_authentication?).and_return(false)
      expect(controller.warden).to receive(:logout).with(:user)

      delete :destroy

      expect(session[:alchemy_devise_original_user_id]).to be_nil
    end

    it "does not restore a user who is no longer an administrator" do
      admin.update!(alchemy_roles: ["member"])
      expect(controller.warden).to receive(:logout).with(:user)

      delete :destroy

      expect(session[:alchemy_devise_original_user_id]).to be_nil
    end

    it "does not sign out an ordinary session without impersonation state" do
      session.delete(:alchemy_devise_original_user_id)
      expect(controller.warden).not_to receive(:logout)

      delete :destroy

      expect(response).to redirect_to(Alchemy.config.unauthorized_path)
    end
  end
end
