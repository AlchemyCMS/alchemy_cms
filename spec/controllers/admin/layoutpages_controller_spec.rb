require 'spec_helper'

module Alchemy
  describe Admin::LayoutpagesController do

    before(:each) do
      sign_in(admin_user)
    end

    describe "#index" do
      it "should assign @locked_pages" do
        get :index
        expect(assigns(:locked_pages)).to eq([])
      end

      it "should assign @layout_root" do
        get :index
        expect(assigns(:layout_root)).to be_a(Page)
      end

      it "should assign @languages" do
        Language.stub!(:all).and_return([])
        get :index
        expect(assigns(:languages)).to eq([])
      end
    end
  end
end
