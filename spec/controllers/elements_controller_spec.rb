require 'spec_helper'

module Alchemy
  describe ElementsController do

    let(:page)       { FactoryGirl.create(:public_page, :restricted => true) }
    let(:element)    { FactoryGirl.create(:element, :page => page, :name => 'download') }

    describe '#show' do

      it "should not return restricted elements" do
        get :show, :id => element.id
        response.status.should == 302
        response.should redirect_to(login_path)
      end

      context "for registered user" do

        before do
          activate_authlogic
          UserSession.create(FactoryGirl.create(:registered_user))
        end

        it "should render restricted elements" do
          get :show, :id => element.id
          response.status.should == 200
        end

      end

    end

  end
end
