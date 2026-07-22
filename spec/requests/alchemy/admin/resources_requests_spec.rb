# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Resource requests" do
  # A dialog form submits into the dialog Turbo Frame, so its request carries
  # the frame id and prefers a turbo_stream response.
  let(:dialog_headers) do
    {
      "Turbo-Frame" => "alchemy_dialog_frame",
      "Accept" => "text/vnd.turbo-stream.html, text/html, application/xhtml+xml"
    }
  end

  before { authorize_user(:as_admin) }

  describe "create from a dialog" do
    context "with invalid params" do
      it "re-renders the form wrapped in the dialog frame with a 422" do
        post "/admin/events", params: {event: {name: ""}}, headers: dialog_headers

        expect(response).to have_http_status(422)
        expect(response.body).to include('<turbo-frame id="alchemy_dialog_frame">')
        expect(response.body).to include("form")
      end
    end

    context "with valid params" do
      it "tells the dialog to close and visit the destination" do
        location = Location.create!(name: "A place")
        post "/admin/events",
          params: {event: {name: "A party", location_id: location.id}},
          headers: dialog_headers

        expect(response.media_type).to eq("text/vnd.turbo-stream.html")
        expect(response.body).to include('action="dialog_visit"')
        expect(response.body).to include("/admin/events")
      end
    end
  end

  describe "create outside a dialog" do
    it "re-renders the form unwrapped with a 422" do
      post "/admin/events", params: {event: {name: ""}}

      expect(response).to have_http_status(422)
      expect(response.body).to include("form")
      expect(response.body).to_not include('<turbo-frame id="alchemy_dialog_frame">')
    end

    it "redirects (see_other) on success" do
      location = Location.create!(name: "A place")
      post "/admin/events", params: {event: {name: "A party", location_id: location.id}}

      expect(response).to have_http_status(:see_other)
      expect(response.location).to include("/admin/events")
    end
  end

  describe "csv export" do
    it "returns valid csv file" do
      get "/admin/events.csv"
      expect(response.media_type).to eq("text/csv")
      expect(response.body).to include(";")
    end

    it "includes id column" do
      event = create(:event)
      get "/admin/events.csv"
      csv = CSV.parse(response.body, col_sep: ";")
      expect(csv[0][0]).to eq("Id")
      expect(csv[1][0]).to eq(event.id.to_s)
    end

    it "body does not truncate long text columns" do
      create(:event, description: "*" * 51)
      get "/admin/events.csv"
      csv = CSV.parse(response.body, col_sep: ";")
      expect(csv[1][7]).to_not include("...")
    end
  end
end
