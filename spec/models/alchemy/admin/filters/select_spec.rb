# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::Filters::Select do
  let(:name) { "by_page_layout" }
  let(:resource_name) { "page" }
  let(:search_form) { "page_search" }
  let(:options) { Alchemy::PageLayout.all.map { |p| [Alchemy.t(p["name"], scope: "page_layout_names"), p["name"]] } }

  let(:checkbox) { described_class.new(name:, resource_name:, search_form:, options:) }

  describe "#applied_filter_component" do
    let(:search_filter_params) { {q: {by_page_layout: "standard"}}.with_indifferent_access }
    let(:resource_url_proxy) { double(url_for: "/admin/pages") }
    let(:query) { double }

    subject(:applied_filter_component) do
      checkbox.applied_filter_component(search_filter_params:, resource_url_proxy:, query:)
    end

    it "returns a dismiss filter component" do
      expect(applied_filter_component).to be_a(Alchemy::Admin::Resource::AppliedFilter)
      expect(applied_filter_component.link).to eq("/admin/pages")
      expect(applied_filter_component.label).to eq("Page Type: Standard")
    end
  end

  describe "#input_component" do
    let(:params) { {q: {by_page_layout: "standard"}}.with_indifferent_access }
    let(:query) { Alchemy::Page.ransack(params[:q]) }

    subject(:component) do
      checkbox.input_component(params, query)
    end

    it "returns a select filter input component" do
      expect(component).to be_a(Alchemy::Admin::Resource::SelectFilter)
      expect(component.name).to eq(name)
      expect(component.label).to eq("Page Type")
      expect(component.search_form).to eq("page_search")
      expect(component.selected).to eq("standard")
    end

    context "when the options are given as a proc" do
      let(:options) do
        ->(_) { Alchemy::PageLayout.all.map { |p| [Alchemy.t(p["name"], scope: "page_layout_names"), p["name"]] } }
      end

      it "returns a select filter input component" do
        expect(component).to be_a(Alchemy::Admin::Resource::SelectFilter)
        expect(component.name).to eq(name)
        expect(component.label).to eq("Page Type")
        expect(component.options).to eq(options.call(query))
        expect(component.search_form).to eq("page_search")
        expect(component.selected).to eq("standard")
      end
    end

    context "when the options are a translatable array" do
      let(:name) { "by_file_format" }
      let(:resource_name) { "picture" }
      let(:search_form) { "picture_search" }
      let(:options) { %w[jpeg png gif] }
      let(:params) { {q: {by_file_format: "jpeg"}}.with_indifferent_access }

      it "returns a select filter input component" do
        expect(component).to be_a(Alchemy::Admin::Resource::SelectFilter)
        expect(component.name).to eq(name)
        expect(component.label).to eq("File Type")
        expect(component.options).to eq([["JPG Image", "jpeg"], ["PNG Image", "png"], ["GIF Image", "gif"]])
        expect(component.search_form).to eq("picture_search")
        expect(component.selected).to eq("jpeg")
      end
    end
  end
end
