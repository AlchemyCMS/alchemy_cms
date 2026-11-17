# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::ResourcesController do
  controller(Admin::EventsController) {}

  it "should include ResourcesHelper" do
    expect(controller.respond_to?(:resource_window_size)).to be_truthy
  end

  before do
    authorize_user(:as_admin)
  end

  describe "#index" do
    let(:params) { {} }
    let!(:peter) { create(:event, name: "Peter") }
    let!(:lustig) { create(:event, name: "Lustig") }

    it "returns all records" do
      get :index, params: params
      expect(assigns(:events)).to include(peter)
      expect(assigns(:events)).to include(lustig)
    end

    context "with search query given" do
      let(:params) { {q: {description_or_hidden_name_or_location_name_or_name_i_cont: "PeTer"}} }

      it "returns only matching records" do
        get :index, params: params
        expect(assigns(:events)).to include(peter)
        expect(assigns(:events)).not_to include(lustig)
      end

      context "but searching for record with certain association" do
        let(:bauwagen) { create(:location, name: "Bauwagen") }
        let(:params) { {q: {description_or_hidden_name_or_location_name_or_name_i_cont: "Bauwagen"}} }

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

      context "with sort parameter given" do
        let(:params) { {q: {s: "name desc"}} }

        it "returns records in the defined order" do
          get :index, params: params
          expect(assigns(:events)).to eq([peter, lustig])
        end
      end

      context "without sort parameter given" do
        context "if resource has name attribute" do
          it "returns records sorted by name" do
            get :index
            expect(assigns(:events)).to eq([lustig, peter])
          end
        end

        context "if resource has no name attribute" do
          let!(:booking1) { Booking.create!(from: 2.week.from_now) }
          let!(:booking2) { Booking.create!(from: 1.weeks.from_now) }

          controller(::Alchemy::Admin::ResourcesController) do
            def resource_handler
              @_resource_handler ||= Alchemy::Resource.new(controller_path, alchemy_module, Booking)
            end
          end

          it "returns records sorted by first attribute" do
            Alchemy::Deprecation.silence do
              get :index
            end
            expect(assigns(:resources)).to eq([booking2, booking1])
          end
        end
      end
    end

    describe "searching for records with multiple associated records" do
      controller(Admin::LocationsController) {}

      let(:bauwagen) { create(:location, name: "Bauwagen") }
      let!(:peter) { create(:event, name: "Peter", location: bauwagen) }
      let!(:lustig) { create(:event, name: "Lustig", location: bauwagen) }

      it "returns only one bauwagen" do
        get :index, params: {q: {events_name_cont: "t"}}
        expect(response).to be_successful
        expect(assigns(:locations)).to eq([bauwagen])
      end
    end
  end

  describe "#update" do
    let(:params) { {q: {description_or_hidden_name_or_location_name_or_name_i_cont: "some_query"}, page: 6} }
    let(:peter) { create(:event, name: "Peter") }

    context "with regular noun model name" do
      it "redirects to index, keeping the current location parameters" do
        post :update, params: {id: peter.id, event: {name: "Hans"}}.merge(params)
        expect(response.redirect_url).to eq("http://test.host/admin/events?page=6&q%5Bdescription_or_hidden_name_or_location_name_or_name_i_cont%5D=some_query")
      end
    end

    context "with zero plural noun model name" do
      let!(:peter) { create(:series, name: "Peter") }
      let(:params) { {q: {name_i_cont: "some_query"}, page: 6} }

      controller(Admin::SeriesController) {}

      it "redirects to index, keeping the current location parameters" do
        post :update, params: {id: peter.id, series: {name: "Hans"}}.merge(params)
        expect(response.redirect_url).to eq("http://test.host/admin/series?page=6&q%5Bname_i_cont%5D=some_query")
      end
    end

    context "with failing validations" do
      subject { post :update, params: {id: peter.id, event: {name: ""}} }

      it "renders edit form" do
        is_expected.to render_template(:edit)
      end

      it "sets 422 status" do
        expect(subject.status).to eq 422
      end
    end

    describe "params security" do
      subject { put :update, params: {id: peter.id, event: {name: "Fox", foo: "bar"}} }

      it "only accepts editable attributes" do
        expect_any_instance_of(Event).to receive(:update).with(
          ActionController::Parameters.new(name: "Fox").permit!
        )
        subject
      end
    end
  end

  describe "#create" do
    let(:params) { {q: {description_or_hidden_name_or_location_name_or_name_i_cont: "some_query"}, page: 6} }
    let!(:location) { create(:location) }

    context "with regular noun model name" do
      it "redirects to index, keeping the current location parameters" do
        post :create, params: {event: {name: "Hans", location_id: location.id}}.merge(params)
        expect(response.redirect_url).to eq("http://test.host/admin/events?page=6&q%5Bdescription_or_hidden_name_or_location_name_or_name_i_cont%5D=some_query")
      end
    end

    context "with zero plural noun model name" do
      let(:params) { {q: {name_i_cont: "some_query"}, page: 6} }

      controller(Admin::SeriesController) {}

      it "redirects to index, keeping the current location parameters" do
        post :create, params: {series: {name: "Hans"}}.merge(params)
        expect(response.redirect_url).to eq("http://test.host/admin/series?page=6&q%5Bname_i_cont%5D=some_query")
      end
    end

    describe "params security" do
      subject { post :create, params: {event: {name: "Fox", foo: "bar"}} }

      it "only accepts editable attributes" do
        expect(Event).to receive(:new).with(
          ActionController::Parameters.new(name: "Fox").permit!
        ).and_call_original
        subject
      end
    end
  end

  describe "#show" do
    let(:event) { create(:event) }

    it "renders the edit template" do
      get :show, params: {id: event.id}
      expect(response).to render_template(:edit)
    end
  end

  describe "#destroy" do
    let(:params) { {q: {description_or_hidden_name_or_location_name_or_name_i_cont: "some_query"}, page: 6} }
    let!(:peter) { create(:event, name: "Peter") }

    it "redirects to index, keeping the current location parameters" do
      delete :destroy, params: {id: peter.id}.merge(params)
      expect(response.redirect_url).to eq("http://test.host/admin/events?page=6&q%5Bdescription_or_hidden_name_or_location_name_or_name_i_cont%5D=some_query")
    end

    context "If the resource is not destroyable" do
      let!(:undestroyable) { create(:event, name: "Undestructible") }

      it "adds an error flash" do
        delete :destroy, params: {id: undestroyable.id}.merge(params)

        expect(response.redirect_url).to eq("http://test.host/admin/events?page=6&q%5Bdescription_or_hidden_name_or_location_name_or_name_i_cont%5D=some_query")
        expect(flash[:error]).to eq("This is the undestructible event!")
      end
    end
  end

  describe "#applied_tags" do
    it "returns the tag names from the tagged_with param" do
      get :index, params: {tagged_with: "workshop, ruby"}
      expect(controller.send(:applied_tags)).to eq(["workshop", "ruby"])
    end

    it "returns an empty array without tags" do
      get :index
      expect(controller.send(:applied_tags)).to eq([])
    end
  end

  describe "#reset_filters_url" do
    let(:search_field) { controller.send(:resource_handler).search_field_name }

    it "keeps the search term, sort order and per page setting, but drops filters, tags and page" do
      get :index, params: {
        q: {"by_location_id" => "1", search_field => "rails", "s" => "name asc"},
        tagged_with: "ruby",
        page: 2,
        per_page: 30
      }
      url = URI.parse(controller.send(:reset_filters_url))

      expect(url.path).to eq("/admin/events")
      expect(Rack::Utils.parse_nested_query(url.query)).to eq(
        "per_page" => "30",
        "q" => {search_field => "rails", "s" => "name asc"}
      )
    end
  end

  describe "#common_search_filter_includes" do
    before do
      allow(controller).to receive(:alchemy_module) { {name: "events"} }
    end

    it "should not be frozen" do
      expect(controller.send(:common_search_filter_includes)).to_not be_frozen
    end
  end
end
