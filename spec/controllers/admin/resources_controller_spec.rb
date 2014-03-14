require "spec_helper"

class EventsController < Alchemy::Admin::ResourcesController
end

describe EventsController do
  it "should include ResourcesHelper" do
    controller.respond_to?(:resource_window_size).should be_true
  end

  describe '#index' do
    let(:params) { Hash.new }
    let(:peter)  { Event.create(name: 'Peter') }
    let(:lustig) { Event.create(name: 'Lustig') }

    before do
      sign_in(admin_user)
      peter; lustig
    end

    it "returns all records" do
      get :index, params
      assigns(:events).should include(peter)
      assigns(:events).should include(lustig)
    end

    context 'with search query given' do
      let(:params) { {query: 'PeTer'} }

      it "returns only matching records" do
        get :index, params
        assigns(:events).should include(peter)
        assigns(:events).should_not include(lustig)
      end
    end
  end
end
