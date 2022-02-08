# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe ElementDefinition do
    describe ".all" do
      # skip memoization
      before { ElementDefinition.instance_variable_set("@definitions", nil) }

      subject { ElementDefinition.all }

      it "should return all element definitions" do
        is_expected.to be_instance_of(Array)
        expect(subject.collect { |l| l["name"] }).to include("slider")
      end
    end

    describe ".add" do
      it "adds a definition to all definitions" do
        ElementDefinition.add({"name" => "foo"})
        expect(ElementDefinition.all).to include({"name" => "foo"})
      end

      it "adds a array of definitions to all definitions" do
        ElementDefinition.add([{"name" => "foo"}, {"name" => "bar"}])
        expect(ElementDefinition.all).to include({"name" => "foo"})
        expect(ElementDefinition.all).to include({"name" => "bar"})
      end
    end

    describe ".get" do
      it "should return the page_layout definition found by given name" do
        allow(ElementDefinition).to receive(:all).and_return([{"name" => "default"}, {"name" => "contact"}])
        expect(ElementDefinition.get("default")).to eq({"name" => "default"})
      end
    end
  end
end
