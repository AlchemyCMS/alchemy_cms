# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Resource requests" do
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

    it "neutralizes spreadsheet formulas in exported values" do
      create(:event, name: "=CMD|'/C calc.exe'!A0")
      get "/admin/events.csv"
      csv = CSV.parse(response.body, col_sep: ";")
      name_column = csv[0].index(Event.human_attribute_name(:name))
      expect(csv[1][name_column]).to eq("\t=CMD|'/C calc.exe'!A0")
    end

    it "quotes every field so that the neutralizing tab survives a spreadsheet round trip" do
      create(:event, name: "=1+1")
      get "/admin/events.csv"
      expect(response.body).to include(%("\t=1+1"))
    end

    it "keeps negative numbers usable as numbers" do
      create(:event, entrance_fee: -5.0)
      get "/admin/events.csv"
      csv = CSV.parse(response.body, col_sep: ";")
      fee_column = csv[0].index(Event.human_attribute_name(:entrance_fee))
      expect(csv[1][fee_column]).to eq("-5.0")
    end

    it "does not allow a column separator in a value to start a new cell" do
      create(:event, name: "Party;=1+1")
      get "/admin/events.csv"
      csv = CSV.parse(response.body, col_sep: ";")
      name_column = csv[0].index(Event.human_attribute_name(:name))
      expect(csv[1][name_column]).to eq("Party;=1+1")
    end
  end
end
