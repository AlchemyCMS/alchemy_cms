# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::Filters::Checkbox do
  let(:name) { "published" }
  let(:resource_name) { "page" }
  let(:search_form) { "page_search" }

  let(:checkbox) { described_class.new(name:, resource_name:, search_form:) }

  describe "#applied_filter_component" do
    let(:search_filter_params) { {q: {published: true}}.with_indifferent_access }
    let(:resource_url_proxy) { double(url_for: "/admin/pages") }
    let(:query) { double }

    subject(:applied_filter_component) do
      checkbox.applied_filter_component(search_filter_params:, resource_url_proxy:, query:)
    end

    it "returns a dismiss filter component" do
      expect(applied_filter_component).to be_a(Alchemy::Admin::Resource::AppliedFilter)
      expect(applied_filter_component.link).to eq("/admin/pages")
      expect(applied_filter_component.label).to eq("Published")
    end
  end

  describe "#input_component" do
    let(:params) { {q: {published: true}}.with_indifferent_access }
    let(:query) { double }

    subject(:component) do
      checkbox.input_component(params, query)
    end

    it "returns a checkbox filter input component" do
      expect(component).to be_a(Alchemy::Admin::Resource::CheckboxFilter)
      expect(component.name).to eq(name)
      expect(component.label).to eq("Published")
      expect(component.search_form).to eq("page_search")
      expect(component.checked).to be true
    end
  end
end
