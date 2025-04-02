# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::Filters::Datepicker do
  let(:name) { "starts_at_gteq" }
  let(:resource_name) { "event" }
  let(:input_type) { :date }
  let(:datepicker) { described_class.new(name:, resource_name:, input_type:) }

  describe "#applied_filter_component" do
    let(:search_filter_params) { {q: {starts_at_gteq: "2025-04-01"}}.with_indifferent_access }
    let(:resource_url_proxy) { double(url_for: "/admin/events") }
    let(:query) { double }

    subject(:applied_filter_component) do
      datepicker.applied_filter_component(search_filter_params:, resource_url_proxy:, query:)
    end

    it "returns a dismiss filter component" do
      expect(applied_filter_component).to be_a(Alchemy::Admin::Resource::AppliedFilter)
      expect(applied_filter_component.link).to eq("/admin/events")
      expect(applied_filter_component.applied_filter_label).to eq("Starts after")
      expect(applied_filter_component.applied_filter_value).to eq("2025-04-01")
    end

    context "when the input_type is :datetime" do
      let(:input_type) { :datetime }

      it "returns a datepicker filter input component with the correct input type and format" do
        expect(applied_filter_component.applied_filter_value).to eq("2025-04-01 00:00")
      end
    end

    context "when the input_type is :time" do
      let(:input_type) { :time }

      it "returns a datepicker filter input component with the correct input type and format" do
        expect(applied_filter_component.applied_filter_value).to eq("00:00")
      end
    end
  end

  describe "#input_component" do
    let(:params) { {q: {starts_at_gteq: "2025-04-01"}}.with_indifferent_access }
    let(:query) { double }

    subject(:component) do
      datepicker.input_component(params, query)
    end

    it "returns a datepicker filter input component" do
      expect(component).to be_a(Alchemy::Admin::Resource::DatepickerFilter)
      expect(component.name).to eq(name)
      expect(component.label).to eq("Starts after")
      expect(component.value).to eq("2025-04-01")
    end
  end
end
