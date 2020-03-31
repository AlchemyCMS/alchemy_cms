# frozen_string_literal: true

require 'rails_helper'

describe Alchemy::Admin::SitesController do
  routes { Alchemy::Engine.routes }

  before do
    authorize_user(:as_admin)
  end

  describe "#create" do
    context 'with valid params' do
      it 'redirects to the languages admin' do
        post :create, params: { site: { host: '*' } }
        site = Alchemy::Site.last
        expect(response).to redirect_to admin_languages_path(site_id: site)
        expect(flash[:notice]).to eq('Please create a default language for this site.')
      end
    end

    context 'with invalid params' do
      it 'shows the form again' do
        post :create, params: { site: { host: '' } }
        expect(response).to render_template(:new)
      end
    end
  end
end
