# frozen_string_literal: true

require 'spec_helper'

module Alchemy
  describe Admin::LayoutpagesController do
    routes { Alchemy::Engine.routes }

    before(:each) do
      authorize_user(:as_admin)
    end

    describe "#index" do
      it "should assign @layout_root" do
        get :index
        expect(assigns(:layout_root)).to be_a(Page)
      end

      it "should assign @languages" do
        get :index
        expect(assigns(:languages).first).to be_a(Language)
      end

      context "with multiple sites" do
        let!(:language) do
          create(:alchemy_language)
        end

        let!(:site_2) do
          create(:alchemy_site, host: 'another-site.com')
        end

        let(:language_2) do
          site_2.default_language
        end

        it 'only shows languages from current site' do
          get :index
          expect(assigns(:languages)).to include(language)
          expect(assigns(:languages)).to_not include(language_2)
        end
      end
    end
  end
end
