# frozen_string_literal: true

require "rails_helper"

describe Alchemy::Admin::PageDefinitionsHelper do
  describe "#page_definition_matches?" do
    subject { helper.page_definition_matches?(page_definition, query) }

    let(:page_definition) { Alchemy::PageDefinition.new(name: "standard", elements: ["gallery"]) }

    context "without query" do
      let(:query) { nil }

      it { is_expected.to be(true) }
    end

    context "with query matching the technical name" do
      let(:query) { "stand" }

      it { is_expected.to be(true) }
    end

    context "with query matching the translated name" do
      let(:page_definition) { Alchemy::PageDefinition.new(name: "everything", elements: []) }
      let(:query) { "Everything" }

      it { is_expected.to be(true) }
    end

    context "with query matching an element name" do
      let(:query) { "gallery" }

      it { is_expected.to be(true) }
    end

    context "with query matching a translated nested element name" do
      let(:query) { "gallery pic" }

      it { is_expected.to be(true) }
    end

    context "with query matching nothing" do
      let(:query) { "slider" }

      it { is_expected.to be(false) }
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
