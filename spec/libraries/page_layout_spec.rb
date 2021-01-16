# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe PageLayout do
    describe ".all" do
      # skip memoization
      before { PageLayout.instance_variable_set("@definitions", nil) }

      subject { PageLayout.all }

      it "should return all page_layouts" do
        is_expected.to be_instance_of(Array)
        expect(subject.collect { |l| l["name"] }).to include("standard")
      end

      it "should allow erb generated layouts" do
        expect(subject.collect { |l| l["name"] }).to include("erb_layout")
      end

      context "with a YAML file including a symbol" do
        let(:yaml) { "name: :symbol" }
        before do
          expect(File).to receive(:exist?).and_return(true)
          expect(File).to receive(:read).and_return(yaml)
        end

        it "returns the definition without error" do
          expect { subject }.to_not raise_error
        end
      end

      context "with empty layouts file" do
        before { expect(YAML).to receive(:safe_load).and_return(false) }

        it "returns empty array" do
          is_expected.to eq([])
        end
      end

      context "with missing layouts file" do
        before { expect(File).to receive(:exist?).and_return(false) }

        it "raises error empty array" do
          expect { subject }.to raise_error(LoadError)
        end
      end
    end

    describe ".add" do
      it "adds a definition to all definitions" do
        PageLayout.add({"name" => "foo"})
        expect(PageLayout.all).to include({"name" => "foo"})
      end

      it "adds a array of definitions to all definitions" do
        PageLayout.add([{"name" => "foo"}, {"name" => "bar"}])
        expect(PageLayout.all).to include({"name" => "foo"})
        expect(PageLayout.all).to include({"name" => "bar"})
      end
    end

    describe ".get" do
      it "should return the page_layout definition found by given name" do
        allow(PageLayout).to receive(:all).and_return([{"name" => "default"}, {"name" => "contact"}])
        expect(PageLayout.get("default")).to eq({"name" => "default"})
      end
    end
  end
end
