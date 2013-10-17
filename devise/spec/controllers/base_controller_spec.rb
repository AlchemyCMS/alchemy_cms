require 'spec_helper'

describe BaseController do

  describe '#store_user_request_time' do
    context "user not logged in" do
      before { controller.stub(:alchemy_user_signed_in?).and_return(false) }

      it "should not store the current request time" do
        controller.send(:store_user_request_time).should == nil
      end
    end

    context "user logged in" do
      before do
        controller.stub(:alchemy_user_signed_in?).and_return(true)
        controller.stub(:current_alchemy_user).and_return(FactoryGirl.create(:user))
      end

      it "should not store the current request time" do
        controller.send(:store_user_request_time).should == true
      end
    end
  end

end
