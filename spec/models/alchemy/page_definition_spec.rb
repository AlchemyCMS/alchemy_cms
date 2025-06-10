# frozen_string_literal: true

require "rails_helper"

module Alchemy
  RSpec.describe PageDefinition, type: :model do
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

    describe "#blank?" do
      subject { definition.blank? }

      context "with name given" do
        let(:definition) { described_class.new(name: "standard") }

        it { is_expected.to be(false) }
      end

      context "without name given" do
        let(:definition) { described_class.new }

        it { is_expected.to be(true) }
      end
    end

    describe "validations" do
      it { is_expected.to validate_presence_of(:name) }
    end

    describe ".all" do
      # skip memoization
      before { PageDefinition.instance_variable_set(:@definitions, nil) }

      subject { PageDefinition.all }

      it "should return all page_layouts" do
        is_expected.to be_instance_of(Array)
        expect(subject).to all be_an(Alchemy::PageDefinition)
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
        PageDefinition.add({"name" => "foo"})
        expect(PageDefinition.map(&:name)).to include("foo")
      end

      it "adds a array of definitions to all definitions" do
        PageDefinition.add([{"name" => "foo"}, {"name" => "bar"}])
        expect(PageDefinition.map(&:name)).to include("foo", "bar")
      end
    end

    describe ".get" do
      it "should return the page_layout definition found by given name" do
        expect(PageDefinition.get("standard").name).to eq("standard")
      end
    end

    describe ".reset!" do
      it "sets @definitions to nil" do
        PageDefinition.all
        PageDefinition.reset!
        expect(PageDefinition.instance_variable_get(:@definitions)).to be_nil
      end
    end
  end
end
