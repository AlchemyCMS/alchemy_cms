# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe Admin::ElementsHelper do
    describe "#elements_for_select" do
      context "passing element instances" do
        let(:element_objects) do
          [
            mock_model("Element", name: "element_1", display_name: "Element 1"),
            mock_model("Element", name: "element_2", display_name: "Element 2"),
          ]
        end

        it "should return a array for option tags" do
          expect(helper.elements_for_select(element_objects)).to include(["Element 1", "element_1"])
          expect(helper.elements_for_select(element_objects)).to include(["Element 2", "element_2"])
        end
      end

      context "passing a hash with element definitions" do
        let(:element_definitions) do
          [{
            "name" => "headline",
            "contents" => [],
          }]
        end

        subject { helper.elements_for_select(element_definitions) }

        it "should return a array for option tags" do
          expect(subject).to include(["Headline", "headline"])
        end

        it "should render the elements display name" do
          expect(Element).to receive(:display_name_for).with("headline")
          subject
        end
      end
    end
  end
end
