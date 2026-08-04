# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::Filters::Select do
  let(:name) { "by_page_layout" }
  let(:resource_name) { "page" }
  let(:options) { Alchemy::PageDefinition.all.map { |p| [Alchemy.t(p["name"], scope: "page_layout_names"), p["name"]] } }

  let(:checkbox) { described_class.new(name:, resource_name:, options:) }

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
      expect(applied_filter_component.applied_filter_label).to eq("Page Type")
      expect(applied_filter_component.applied_filter_value).to eq("Standard")
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
      expect(component.selected).to eq("standard")
    end

    context "when the options are given as a nested array" do
      let(:options) do
        ->(_) { Alchemy::PageDefinition.all.map { |p| [Alchemy.t(p["name"], scope: "page_layout_names"), p["name"]] } }
      end

      it "returns a select filter input component with given options" do
        expect(component).to be_a(Alchemy::Admin::Resource::SelectFilter)
        expect(component.name).to eq(name)
        expect(component.label).to eq("Page Type")
        expect(component.options).to eq(options.call(query))
        expect(component.selected).to eq("standard")
      end
    end

    context "when the options are given as block with params argument" do
      let(:params) { {only: ["standard"]} }

      let(:options) do
        ->(_q, params) { params[:only] }
      end

      it "returns a select filter input component with options from params" do
        expect(component).to be_a(Alchemy::Admin::Resource::SelectFilter)
        expect(component.name).to eq(name)
        expect(component.label).to eq("Page Type")
        expect(component.options).to eq([["Standard", "standard"]])
      end
    end

    context "when the options are a translatable array" do
      let(:name) { "by_file_format" }
      let(:resource_name) { "picture" }
      let(:search_form) { "picture_search" }
      let(:options) { %w[jpeg png gif] }
      let(:params) { {q: {by_file_format: "jpeg"}}.with_indifferent_access }

      it "returns a select filter input component with translated options" do
        expect(component).to be_a(Alchemy::Admin::Resource::SelectFilter)
        expect(component.name).to eq(name)
        expect(component.label).to eq("File Type")
        expect(component.options).to eq([["JPG Image", "jpeg"], ["PNG Image", "png"], ["GIF Image", "gif"]])
        expect(component.selected).to eq("jpeg")
      end
    end

    context "when the options are a flat array" do
      let(:name) { "by_array" }
      let(:resource_name) { "foo" }
      let(:search_form) { "array_search" }
      let(:options) { %w[A B C] }
      let(:params) { {q: {by_array: "B"}}.with_indifferent_access }

      it "returns a select filter input component with translated options" do
        expect(component).to be_a(Alchemy::Admin::Resource::SelectFilter)
        expect(component.options).to eq([["A", "A"], ["B", "B"], ["C", "C"]])
        expect(component.selected).to eq("B")
      end
    end

    context "when multiple/include_blank are not given" do
      it "defaults to multiple: false and a translated blank option" do
        expect(component.multiple).to be false
        expect(component.include_blank).to eq("All page types")
      end
    end

    context "when multiple is given as a boolean" do
      let(:checkbox) { described_class.new(name:, resource_name:, options:, multiple: true) }

      it "returns a select filter input component with multiple selection enabled" do
        expect(component.multiple).to be true
      end
    end

    context "when multiple is given as a proc" do
      let(:params) { {q: {by_page_layout: "standard"}, only: ["standard", "news"]} }
      let(:checkbox) { described_class.new(name:, resource_name:, options:, multiple: ->(params) { params[:only].present? }) }

      it "calls the proc with the search filter params" do
        expect(component.multiple).to be true
      end
    end

    context "when include_blank is given as a boolean" do
      let(:checkbox) { described_class.new(name:, resource_name:, options:, include_blank: false) }

      it "returns a select filter input component without a blank option" do
        expect(component.include_blank).to be false
      end
    end

    context "when include_blank is given as a string" do
      let(:checkbox) { described_class.new(name:, resource_name:, options:, include_blank: "Choose one") }

      it "returns a select filter input component with the given blank option label" do
        expect(component.include_blank).to eq("Choose one")
      end
    end

    context "when include_blank is given as a proc" do
      let(:params) { {q: {by_page_layout: "standard"}, only: ["standard"]} }
      let(:checkbox) { described_class.new(name:, resource_name:, options:, include_blank: ->(params) { params[:only].blank? }) }

      it "calls the proc with the search filter params" do
        expect(component.include_blank).to be false
      end
    end
  end
end
