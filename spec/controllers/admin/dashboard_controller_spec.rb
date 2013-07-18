require 'spec_helper'

module Alchemy
  describe Admin::DashboardController do

    before do
      sign_in(admin_user)
    end

    describe '#index' do
      before do
        Page.stub_chain(:from_current_site, :all_last_edited_from).and_return([])
        Page.stub_chain(:from_current_site, :all_locked).and_return([])
        User.stub(:logged_in).and_return([controller.current_user])
        controller.current_user.stub(:sign_in_count).and_return(5)
      end

      it "should assign @last_edited_pages" do
        get :index
        expect(assigns(:last_edited_pages)).to eq([])
      end

      it "should assign @locked_pages" do
        get :index
        expect(assigns(:locked_pages)).to eq([])
      end

      it "should assign @online_users" do
        get :index
        expect(assigns(:online_users)).to eq([])
      end

      it "should assign @first_time" do
        get :index
        expect(assigns(:first_time)).to eq(false)
      end

      it "should assign @sites" do
        get :index
        expect(assigns(:sites)).to eq(Site.all)
      end
    end

    describe '#info' do
      it "should assign @alchemy_version with the current Alchemy version" do
        get :info
        expect(assigns(:alchemy_version)).to eq(Alchemy.version)
      end
    end

    describe '#update_check' do

      context "if current Alchemy version equals the latest released version or it is newer" do
        before do
          controller.stub(:latest_alchemy_version).and_return('2.6')
          Alchemy.stub(:version).and_return("2.6")
        end

        it "should render 'false'" do
          get :update_check
          expect(response.body).to eq('false')
        end
      end

      context "if current Alchemy version is older than latest released version" do
        before do
          controller.stub(:latest_alchemy_version).and_return('2.6')
          Alchemy.stub(:version).and_return("2.5")
        end

        it "should render 'true'" do
          get :update_check
          expect(response.body).to eq('true')
        end
      end

      context "requesting rubygems.org" do
        before do
          Net::HTTP.any_instance.stub(:request).and_return(
            OpenStruct.new({code: '200', body: '[{"number": "2.6"}, {"number": "2.5"}]'})
          )
          Alchemy.stub(:version).and_return("2.6")
        end

        it "should have response code of 200" do
          get :update_check
          expect(response.code).to eq('200')
        end
      end

      context "requesting github.com" do
        before do
          controller.stub(:query_rubygems).and_return(OpenStruct.new({code: '503'}))
          Net::HTTP.any_instance.stub(:request).and_return(
            OpenStruct.new({code: '200', body: '[{"name": "2.6"}, {"name": "2.5"}]'})
          )
        end

        it "should have response code of 200" do
          get :update_check
          expect(response.code).to eq('200')
        end
      end

      context "rubygems.org and github.com are unavailable" do
        before do
          Net::HTTP.any_instance.stub(:request).and_return(
            OpenStruct.new({code: '503'})
          )
        end

        it "should have status code 503" do
          get :update_check
          expect(response.code).to eq('503')
        end
      end

    end

  end
end
