require 'spec_helper'

describe Alchemy::UserSessionsController do
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  context 'without users present' do
    describe '#new' do
      it "redirects to signup form" do
        get :new
        should redirect_to(signup_path)
      end
    end
  end

  context 'with users present' do
    let(:user) { create(:admin_user) }

    describe '#create' do
      context 'with valid user' do
        let(:screen_size) {'1200x800'}
        let(:user_params) { {login: user.login, password: 's3cr3t'} }

        before { user }

        context 'without redirect path in session' do
          it "redirects to dashboard" do
            post :create, user: user_params
            response.should redirect_to(admin_dashboard_path)
          end
        end

        context 'with redirect path in session' do
          it "redirects to these params" do
            session[:redirect_path] = admin_users_path
            post :create, user: user_params
            response.should redirect_to(admin_users_path)
          end
        end

        it "stores users screen size" do
          post :create, user: user_params, user_screensize: screen_size
          session[:screen_size].should eq(screen_size)
        end

        context 'without valid params' do
          it "renders login form" do
            post :create, user: {login: ''}
            should render_template(:new)
          end
        end
      end
    end

    describe "#destroy" do
      before do
        controller.stub(:store_user_request_time)
        sign_in(user)
      end

      it "should unlock all pages" do
        user.should_receive(:unlock_pages!)
        delete :destroy
      end

      context 'comming from admin area' do
        before { controller.request.stub(:referer).and_return('/admin_users') }

        it "redirects to root" do
          delete :destroy
          should redirect_to(root_path)
        end
      end

      context 'no referer present' do
        before { controller.request.stub(:referer) }

        it "redirects to root" do
          delete :destroy
          should redirect_to(root_path)
        end
      end

      context 'referer not from admin area' do
        before { controller.request.stub(:referer).and_return('/imprint') }

        it "redirects to root" do
          delete :destroy
          should redirect_to('/imprint')
        end
      end
    end
  end
end
