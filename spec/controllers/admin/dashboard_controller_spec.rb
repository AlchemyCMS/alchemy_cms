require 'spec_helper'

module Alchemy
  describe Admin::DashboardController do

    before do
      sign_in :user, FactoryGirl.create(:admin_user)
    end
    
    describe '#info' do
      it "should assign @alchemy_version with the current Alchemy version" do
        get :info
        expect(assigns(:alchemy_version)).to eq(Alchemy.version)
      end
    end

    describe '#update_check' do

      before do
        Net::HTTP.any_instance.stub(:request).and_return(
          OpenStruct.new({code: '200', body: '[{"number": "2.6"}, {"number": "2.5"}]'})
        )
      end

      context "if current Alchemy version equals the latest released version or it is newer" do
        before { Alchemy.stub!(:version).and_return("2.6") }

        it "should render 'false'" do
          get :update_check
          expect(response.body).to eq('false')
        end
      end

      context "if current Alchemy version is older than latest released version" do
        before { Alchemy.stub!(:version).and_return("2.5") }

        it "should render 'true'" do
          get :update_check
          expect(response.body).to eq('true')
        end
      end

    end

  end
end
