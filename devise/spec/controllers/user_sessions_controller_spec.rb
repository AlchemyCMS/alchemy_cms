require 'spec_helper'

describe Alchemy::UserSessionsController do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  context 'without users present' do
    describe '#new' do
      it "redirects to signup form" do
        get :new
        is_expected.to redirect_to(signup_path)
      end

      context 'with ssl enforced' do
        before do
          allow(controller).to receive(:ssl_required?).and_return(true)
        end

        it 'redirects to https' do
          get :new
          is_expected.to redirect_to(
            login_url(protocol: 'https', host: "test.host")
          )
        end
      end
    end
  end

  context 'with users present' do
    let(:user) { create(:alchemy_admin_user) }

    describe '#create' do
      context 'with valid user' do
        let(:screen_size) {'1200x800'}
        let(:user_params) { {login: user.login, password: 's3cr3t'} }

        before { user }

        context 'without redirect path in session' do
          it "redirects to dashboard" do
            post :create, user: user_params
            expect(response).to redirect_to(admin_dashboard_path)
          end
        end

        context 'with redirect path in session' do
          it "redirects to these params" do
            session[:redirect_path] = admin_users_path
            post :create, user: user_params
            expect(response).to redirect_to(admin_users_path)
          end
        end

        it "stores users screen size" do
          post :create, user: user_params, user_screensize: screen_size
          expect(session[:screen_size]).to eq(screen_size)
        end

        context 'without valid params' do
          it "renders login form" do
            post :create, user: {login: ''}
            is_expected.to render_template(:new)
          end
        end
      end
    end

    describe "#destroy" do
      before do
        allow(controller).to receive(:store_user_request_time)
        allow(controller)
          .to receive(:all_signed_out?)
          .and_return(false)
        sign_in(user)
      end

      it "should unlock all pages" do
        expect(user).to receive(:unlock_pages!)
        delete :destroy
      end

      context 'comming from admin area' do
        before do
          allow(controller.request)
            .to receive(:referer)
            .and_return('/admin_users')
        end

        it "redirects to root" do
          delete :destroy
          is_expected.to redirect_to(root_path)
        end
      end

      context 'no referer present' do
        before do
          allow(controller.request)
            .to receive(:referer)
            .and_return(nil)
        end

        it "redirects to root" do
          delete :destroy
          is_expected.to redirect_to(root_path)
        end
      end

      context 'referer not from admin area' do
        before do
          allow(controller.request)
            .to receive(:referer)
            .and_return('/imprint')
        end

        it "redirects to root" do
          delete :destroy
          is_expected.to redirect_to('/imprint')
        end
      end
    end
  end
end
