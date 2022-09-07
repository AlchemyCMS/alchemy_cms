# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Element::DomId do
  describe "#call" do
    subject(:dom_id) do
      described_class.new(element).call
    end

    let(:element) { build_stubbed(:alchemy_element, position: 1) }

    it "returns a string from element name and position" do
      expect(dom_id).to eq("#{element.name}-#{element.position}")
    end

    context "with a parent element" do
      let(:parent_element) do
        build_stubbed(:alchemy_element, position: 1)
      end

      let(:element) do
        build_stubbed(:alchemy_element, position: 1, parent_element: parent_element)
      end

      it "returns a string from element name and position" do
        expect(dom_id).to eq("#{parent_element.name}-#{parent_element.position}-#{element.name}-#{element.position}")
      end
    end
  end
end
