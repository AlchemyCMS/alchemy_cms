# frozen_string_literal: true

require 'spec_helper'

describe Alchemy::Admin::DashboardController do
  routes { Alchemy::Engine.routes }

  context "in admin backend" do
    let(:dummy_user) { mock_model(Alchemy.user_class, alchemy_roles: %w(admin), language: 'de') }

    before { authorize_user(dummy_user) }

    it "should be possible to set the locale of the admin backend via params" do
      get :index, params: {admin_locale: 'nl'}
      expect(::I18n.locale).to eq(:nl)
    end

    it "should store the current locale in the session" do
      get :index, params: {admin_locale: 'nl'}
      expect(session[:alchemy_locale]).to eq(:nl)
    end

    it "should be possible to change the current locale in the session" do
      get :index, params: {admin_locale: 'de'}
      expect(session[:alchemy_locale]).to eq(:de)
      get :index, params: {admin_locale: 'en'}
      expect(session[:alchemy_locale]).to eq(:en)
    end

    context 'with unknown locale' do
      it "it uses the users default language" do
        get :index, params: {admin_locale: 'ko'}
        expect(::I18n.locale).to eq(:de)
      end
    end

    context "if no other parameter is given" do
      it "should use the current users language setting" do
        get :index
        expect(::I18n.locale).to eq(:de)
      end

      context "if user has no preferred locale" do
        let(:dummy_user) { mock_model(Alchemy.user_class, alchemy_roles: %w(admin), language: nil) }

        it "should use the browsers language setting" do
          request.headers['ACCEPT-LANGUAGE'] = 'es-ES'
          get :index
          expect(::I18n.locale).to eq(:es)
        end
      end

      context "if user language is an instance of a model" do
        let(:language) { create(:alchemy_language) }
        let(:dummy_user) { mock_model(Alchemy.user_class, alchemy_roles: %w(admin), language: language) }

        context "if language doesn't return a valid locale symbol" do
          it "should use the browsers language setting" do
            request.headers['ACCEPT-LANGUAGE'] = 'es-ES'
            get :index
            expect(::I18n.locale).to eq(:es)
          end
        end

        context "if language returns a valid locale symbol" do
          before { allow(language).to receive(:to_sym).and_return(:nl) }

          it "should use the locale of the user language" do
            get :index
            expect(::I18n.locale).to eq(:nl)
          end
        end
      end
    end
  end
end
