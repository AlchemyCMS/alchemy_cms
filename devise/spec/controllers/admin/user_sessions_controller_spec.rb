# frozen_string_literal: true

require "rails_helper"

describe Alchemy::Admin::UserSessionsController do
  routes { Alchemy::Engine.routes }

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  context "without users present" do
    describe "#new" do
      it "redirects to signup form" do
        get :new
        is_expected.to redirect_to(admin_signup_path)
      end
    end
  end

  context "with users present" do
    let(:user) { create(:alchemy_admin_user) }

    describe "#create" do
      context "with valid user" do
        let(:screen_size) { "1200x800" }
        let(:user_params) { { login: user.login, password: "s3cr3t" } }

        before { user }

        context "without redirect path in session" do
          it "redirects to dashboard" do
            post :create, params: { user: user_params }
            expect(response).to redirect_to(admin_dashboard_path)
          end
        end

        context "with redirect path in session" do
          it "redirects to these params" do
            session[:redirect_path] = admin_users_path
            post :create, params: { user: user_params }
            expect(response).to redirect_to(admin_users_path)
          end
        end

        context "without valid params" do
          it "renders login form" do
            post :create, params: { user: { login: "" } }
            is_expected.to render_template(:new)
          end
        end
      end
    end

    describe "#destroy" do
      before do
        allow(controller).to receive(:store_user_request_time)
        allow(controller).to receive(:all_signed_out?)
                               .and_return(false)
        authorize_user(user)
      end

      it "should unlock all pages" do
        expect(user).to receive(:unlock_pages!)
        delete :destroy
      end

      context "comming from admin area" do
        before do
          allow_any_instance_of(ActionController::TestRequest).to receive(:referer) do
            "/admin_users"
          end
        end

        it "redirects to root" do
          delete :destroy
          is_expected.to redirect_to(root_path)
        end
      end

      context "no referer present" do
        before do
          allow_any_instance_of(ActionController::TestRequest).to receive(:referer) do
            nil
          end
        end

        it "redirects to root" do
          delete :destroy
          is_expected.to redirect_to(root_path)
        end
      end

      context "referer not from admin area" do
        before do
          allow_any_instance_of(ActionController::TestRequest).to receive(:referer) do
            "/imprint"
          end
        end

        it "redirects to root" do
          delete :destroy
          is_expected.to redirect_to("/imprint")
        end
      end
    end
  end
end
