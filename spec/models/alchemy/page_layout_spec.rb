# frozen_string_literal: true

require "rails_helper"

module Alchemy
  RSpec.describe PageLayout, type: :model do
    describe "#attributes" do
      let(:definition) { described_class.new(name: "standard") }

      subject { definition.attributes }

      it { is_expected.to have_key(:name) }
      it { is_expected.to have_key(:elements) }
      it { is_expected.to have_key(:autogenerate) }
      it { is_expected.to have_key(:layoutpage) }
      it { is_expected.to have_key(:unique) }
      it { is_expected.to have_key(:cache) }
      it { is_expected.to have_key(:searchable) }
      it { is_expected.to have_key(:searchresults) }
      it { is_expected.to have_key(:hide) }
      it { is_expected.to have_key(:editable_by) }
      it { is_expected.to have_key(:hint) }
    end

    describe "validations" do
      it { is_expected.to validate_presence_of(:name) }
    end

    describe ".all" do
      # skip memoization
      before { PageLayout.instance_variable_set(:@definitions, nil) }

      subject { PageLayout.all }

      it "should return all page_layouts" do
        is_expected.to be_instance_of(Array)
        expect(subject).to all be_an(Alchemy::PageLayout)
        expect(subject.map(&:name)).to include("standard")
      end

      it "should allow erb generated layouts" do
        expect(subject.map(&:name)).to include("erb_layout")
      end

      context "with a YAML file including a symbol" do
        let(:yaml) { "name: :symbol" }
        before do
          allow(File).to receive(:exist?).and_return(true)
          allow(File).to receive(:read).and_return(yaml)
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
        expect(PageLayout.map(&:name)).to include("foo")
      end

      it "adds a array of definitions to all definitions" do
        PageLayout.add([{"name" => "foo"}, {"name" => "bar"}])
        expect(PageLayout.map(&:name)).to include("foo", "bar")
      end
    end

    describe ".get" do
      it "should return the page_layout definition found by given name" do
        expect(PageLayout.get("standard").name).to eq("standard")
      end
    end

    describe ".reset!" do
      it "sets @definitions to nil" do
        PageLayout.all
        PageLayout.reset!
        expect(PageLayout.instance_variable_get(:@definitions)).to be_nil
      end
    end
  end
end
