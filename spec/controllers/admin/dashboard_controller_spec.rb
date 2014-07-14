require 'spec_helper'

Alchemy::Admin::Dashboard::Widget.setup do |w|
  w.name = "My Widget"
  w.label = "Label"
end

module Alchemy::Admin
  describe DashboardController do
    before do
      sign_in(admin_user)
    end

    describe '#index' do
      it "should assign @widgets with list of widgets" do
        get :index
        expect(assigns(:widgets)).to eq([Alchemy::Admin::Dashboard::Widget])
      end
    end

  end
end
