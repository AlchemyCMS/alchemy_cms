require 'spec_helper'

module Alchemy::Admin
  describe DashboardController do
    let(:my_widget) do
      Alchemy::Admin::WidgetConfig.new(:my_widget, {state: :dashboard})
    end

    let(:date) { "2014-07-05 14:23:41".to_date }

    before do
      Alchemy::Admin::Dashboard.register_widget 'my_widget'
      sign_in(admin_user)
    end

    describe '#index' do
      it "should assign @widgets with list of widgets" do
        get :index
        expect(assigns(:widgets)).to eq([my_widget])
      end
    end

  end
end
