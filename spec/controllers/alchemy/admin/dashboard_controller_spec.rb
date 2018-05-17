# frozen_string_literal: true

require 'spec_helper'

module Alchemy
  describe Admin::DashboardController do
    routes { Alchemy::Engine.routes }

    let(:user) { build_stubbed(:alchemy_dummy_user, :as_admin) }

    before { authorize_user(user) }

    describe '#index' do
      before do
        allow(Page).to receive(:from_current_site).and_return(
          double(
            all_last_edited_from: [],
            locked_by: [],
            locked: []
          )
        )
      end

      it "assigns @last_edited_pages" do
        get :index
        expect(assigns(:last_edited_pages)).to eq([])
      end

      it "assigns @all_locked_pages" do
        get :index
        expect(assigns(:all_locked_pages)).to eq([])
      end

      context 'with user class having logged_in scope' do
        context 'with other users online' do
          let(:another_user) { mock_model('DummyUser') }

          before do
            expect(Alchemy.user_class).to receive(:logged_in).and_return([another_user])
          end

          it "assigns @online_users" do
            get :index
            expect(assigns(:online_users)).to eq([another_user])
          end
        end

        context 'without other users online' do
          it "does not assign @online_users" do
            get :index
            expect(assigns(:online_users)).to eq([])
          end
        end
      end

      context 'user having signed in before' do
        before do
          expect(user).to receive(:sign_in_count).and_return(5)
          expect(user).to receive(:last_sign_in_at).and_return(Time.current)
        end

        it "assigns @first_time" do
          get :index
          expect(assigns(:first_time)).to eq(false)
        end
      end

      it "assigns @sites" do
        get :index
        expect(assigns(:sites)).to eq(Site.all)
      end
    end

    describe '#info' do
      it "assigns @alchemy_version with the current Alchemy version" do
        get :info
        expect(assigns(:alchemy_version)).to eq(Alchemy.version)
      end
    end

    describe '#update_check' do
      context "if current Alchemy version equals the latest released version or it is newer" do
        before {
          allow(controller).to receive(:latest_alchemy_version).and_return('2.6')
          allow(Alchemy).to receive(:version).and_return("2.6")
        }

        it "should render 'false'" do
          get :update_check
          expect(response.body).to eq('false')
        end
      end

      context "if current Alchemy version is older than latest released version" do
        before do
          allow_any_instance_of(Net::HTTP).to receive(:request) do
            OpenStruct.new({code: '200', body: '[{"number": "2.6"}, {"number": "2.5"}]'})
          end
          allow(Alchemy).to receive(:version).and_return("2.5")
        end

        it "should render 'true'" do
          get :update_check
          expect(response.body).to eq('true')
        end
      end

      context "requesting rubygems.org" do
        before {
          allow_any_instance_of(Net::HTTP).to receive(:request).and_return(
            OpenStruct.new({code: '200', body: '[{"number": "2.6"}, {"number": "2.5"}]'})
          )
          allow(Alchemy).to receive(:version).and_return("2.6")
        }

        it "should have response code of 200" do
          get :update_check
          expect(response.code).to eq('200')
        end
      end

      context "requesting github.com" do
        before {
          allow(controller).to receive(:query_rubygems).and_return(OpenStruct.new({code: '503'}))
          allow_any_instance_of(Net::HTTP).to receive(:request).and_return(
            OpenStruct.new({code: '200', body: '[{"name": "2.6"}, {"name": "2.5"}]'})
          )
        }

        it "should have response code of 200" do
          get :update_check
          expect(response.code).to eq('200')
        end
      end

      context "rubygems.org and github.com are unavailable" do
        before {
          allow_any_instance_of(Net::HTTP).to receive(:request).and_return(
            OpenStruct.new({code: '503'})
          )
        }

        it "should have status code 503" do
          get :update_check
          expect(response.code).to eq('503')
        end
      end
    end
  end
end
