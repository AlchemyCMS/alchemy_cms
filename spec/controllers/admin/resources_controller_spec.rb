require "spec_helper"

class EventsController < Alchemy::Admin::ResourcesController
end

describe EventsController, :type => :controller do
  it "should include ResourcesHelper" do
    expect(controller.respond_to?(:resource_window_size)).to be_truthy
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
      expect(assigns(:events)).to include(peter)
      expect(assigns(:events)).to include(lustig)
    end

    context 'with search query given' do
      let(:params) { {query: 'PeTer'} }

      it "returns only matching records" do
        get :index, params
        expect(assigns(:events)).to include(peter)
        expect(assigns(:events)).not_to include(lustig)
      end
    end
  end
end
