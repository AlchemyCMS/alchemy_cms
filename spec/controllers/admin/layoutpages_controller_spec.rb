require 'spec_helper'

module Alchemy
  describe Admin::LayoutpagesController do

    before(:each) do
      authorize_user(:as_admin)
    end

    describe "#index" do
      it "should assign @locked_pages" do
        alchemy_get :index
        expect(assigns(:locked_pages)).to eq([])
      end

      it "should assign @layout_root" do
        alchemy_get :index
        expect(assigns(:layout_root)).to be_a(Page)
      end

      it "should assign @languages" do
        alchemy_get :index
        expect(assigns(:languages).first).to be_a(Language)
      end
    end
  end
end
