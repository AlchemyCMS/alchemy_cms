require 'ostruct'
require 'spec_helper'

module Alchemy
  describe Admin::SitesController do
    let!(:a_site) { FactoryGirl.create(:site) }

    context 'a guest' do
      it 'can not access site switch' do
        alchemy_get :select, id: a_site.id
        expect(response).to be_redirect
      end
    end

    context 'a member' do
      before { authorize_user(build(:alchemy_dummy_user)) }

      it 'can not access site switch' do
        alchemy_get :select, id: a_site.id
        expect(response).to be_redirect
      end
    end

    context 'with logged in editor user' do
      let(:user) { build(:alchemy_dummy_user, :as_admin) }
      before { authorize_user(user) }

      it 'can access site switch' do
        expect{
          alchemy_get :select, redirect_to: "http://www.google.de", id: a_site.id
        }.to change{ session[:site_id] }.to a_site.id.to_s
        expect(response).to redirect_to("http://www.google.de")
      end
    end
  end
end
