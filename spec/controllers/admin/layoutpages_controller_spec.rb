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
        get :index
        expect(assigns(:languages).first).to be_a(Language)
      end
    end
  end
end
