require 'spec_helper'

module Alchemy
  describe Admin::LayoutpagesController do

    before(:each) do
      authorize_user(:as_admin)
    end

    describe "#index" do
      it "should assign @layoutpages" do
        alchemy_get :index
        expect(assigns(:layoutpages)).to eq(Page.layoutpages)
      end

      it "should assign @languages" do
        alchemy_get :index
        expect(assigns(:languages).first).to be_a(Language)
      end
    end
  end
end
