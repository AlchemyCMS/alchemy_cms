# frozen_string_literal: true

require "rails_helper"

describe Alchemy::Admin::PageDefinitionsHelper do
  describe "#page_definitions_filter_path" do
    it "returns the unfiltered path without arguments" do
      expect(helper.page_definitions_filter_path).to eq("/admin/page_definitions")
    end

    it "filters by page type and keeps the query" do
      expect(helper.page_definitions_filter_path(page_type: "news", query: "head")).to eq(
        "/admin/page_definitions?q%5Bname_eq%5D=news&q%5Bname_or_elements_cont%5D=head"
      )
    end

    it "adds an anchor" do
      expect(helper.page_definitions_filter_path(query: "head", anchor: "news")).to eq(
        "/admin/page_definitions?q%5Bname_or_elements_cont%5D=head#news"
      )
    end

    it "omits blank values" do
      expect(helper.page_definitions_filter_path(page_type: "news", query: "")).to eq(
        "/admin/page_definitions?q%5Bname_eq%5D=news"
      )
    end
  end

  describe "#nested_element_matches?" do
    subject { helper.nested_element_matches?(element_name, query) }

    let(:element_name) { "gallery" }

    context "with query matching a nested element" do
      let(:query) { "Gallery picture" }

      it { is_expected.to be(true) }
    end

    context "with query matching only the element itself" do
      let(:element_name) { "slider" }
      let(:query) { "slider" }

      it "is false, because the element is visible already" do
        is_expected.to be(false)
      end
    end

    context "with an element nesting itself" do
      let(:element_name) { "box" }
      let(:query) { "nothing" }

      before do
        allow(Alchemy::ElementDefinition).to receive(:get).with("box") do
          Alchemy::ElementDefinition.new(name: "box", nestable_elements: ["box"])
        end
      end

      it { is_expected.to be(false) }
    end
  end
end
