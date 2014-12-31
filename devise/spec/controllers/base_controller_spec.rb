require 'spec_helper'

describe Alchemy::BaseController do

  describe '#store_user_request_time' do
    context "user not logged in" do
      before { allow(controller).to receive(:alchemy_user_signed_in?).and_return(false) }

      it "should not store the current request time" do
        expect(controller.send(:store_user_request_time)).to eq(nil)
      end
    end

    context "user logged in" do
      before do
        allow(controller).to receive(:alchemy_user_signed_in?).and_return(true)
        allow(controller).to receive(:current_alchemy_user).and_return(mock_model('User', store_request_time!: true))
      end

      it "should not store the current request time" do
        expect(controller.send(:store_user_request_time)).to eq(true)
      end
    end
  end

end
