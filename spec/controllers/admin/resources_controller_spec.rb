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
      get :index, params
      expect(assigns(:events)).to include(peter)
      expect(assigns(:events)).to include(lustig)
    end

    context 'with search query given' do
      let(:params) { {q: {name_or_hidden_name_or_location_name_cont: "PeTer"}} }

      it "returns only matching records" do
        get :index, params
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
          get :index, params
          expect(assigns(:events)).to include(peter)
          expect(assigns(:events)).not_to include(lustig)
        end
      end
    end
  end
end
