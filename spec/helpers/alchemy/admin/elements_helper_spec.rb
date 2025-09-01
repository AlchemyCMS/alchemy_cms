# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe Admin::ElementsHelper do
    describe "#elements_for_select" do
      before do
        allow(Element).to receive(:icon_file)
      end

      let(:element_definitions) do
        [
          ElementDefinition.new(
            "name" => "headline"
          )
        ]
      end

      subject { helper.elements_for_select(element_definitions) }

      it "should return a array of options for element-select" do
        expect(subject).to match_array([
          {
            text: "Headline",
            icon: an_instance_of(ActiveSupport::SafeBuffer),
            id: "headline"
          }
        ])
      end

      it "should render the elements display name" do
        expect(Element).to receive(:display_name_for).with("headline")
        subject
      end
    end
  end
end
