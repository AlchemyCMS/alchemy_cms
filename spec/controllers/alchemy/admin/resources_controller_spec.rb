require "spec_helper"

class Admin::EventsController < Alchemy::Admin::ResourcesController
end

describe Admin::EventsController do
  it "should include ResourcesHelper" do
    expect(controller.respond_to?(:resource_window_size)).to be_truthy
  end

  describe '#index' do
    let(:params)  { Hash.new }
    let!(:peter)  { Event.create(name: 'Peter') }
    let!(:lustig) { Event.create(name: 'Lustig') }

    before do
      authorize_user(:as_admin)
    end

    it "returns all records" do
      get :index, params: params
      expect(assigns(:events)).to include(peter)
      expect(assigns(:events)).to include(lustig)
    end

    context 'with search query given' do
      let(:params) { {q: {name_or_hidden_name_or_location_name_cont: "PeTer"}} }

      it "returns only matching records" do
        get :index, params: params
        expect(assigns(:events)).to include(peter)
        expect(assigns(:events)).not_to include(lustig)
      end

      context "but searching for record with certain association" do
        let(:bauwagen) { Location.create(name: 'Bauwagen') }
        let(:params)   { {q: {name_or_hidden_name_or_location_name_cont: "Bauwagen"}} }

        before do
          peter.location = bauwagen
          peter.save
        end

        it "returns only matching records" do
          get :index, params: params
          expect(assigns(:events)).to include(peter)
          expect(assigns(:events)).not_to include(lustig)
        end
      end
    end
  end

  describe '#update' do
    let(:params) { {q: 'some_query', page: 6} }
    let!(:peter)  { Event.create(name: 'Peter') }

    it 'redirects to index, keeping the current location parameters' do
      post :update, params: {id: peter.id, event: {name: "Hans"}}.merge(params)
      expect(response.redirect_url).to eq("http://test.host/admin/events?page=6&q=some_query")
    end
  end

  describe '#create' do
    let(:params) { {q: 'some_query', page: 6} }

    it 'redirects to index, keeping the current location parameters' do
      post :create, params: {event: {name: "Hans"}}.merge(params)
      expect(response.redirect_url).to eq("http://test.host/admin/events?page=6&q=some_query")
    end
  end

  describe '#destroy' do
    let(:params) { {q: 'some_query', page: 6} }
    let!(:peter)  { Event.create(name: 'Peter') }

    it 'redirects to index, keeping the current location parameters' do
      delete :destroy, params: {id: peter.id}.merge(params)
      expect(response.redirect_url).to eq("http://test.host/admin/events?page=6&q=some_query")
    end
  end
end
