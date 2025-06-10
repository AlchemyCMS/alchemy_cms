# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe ElementDefinition do
    describe "#attributes" do
      let(:definition) { described_class.new(name: "standard") }

      subject { definition.attributes }

      it { is_expected.to have_key(:name) }
      it { is_expected.to have_key(:unique) }
      it { is_expected.to have_key(:amount) }
      it { is_expected.to have_key(:taggable) }
      it { is_expected.to have_key(:compact) }
      it { is_expected.to have_key(:fixed) }
      it { is_expected.to have_key(:ingredients) }
      it { is_expected.to have_key(:nestable_elements) }
      it { is_expected.to have_key(:autogenerate) }
      it { is_expected.to have_key(:deprecated) }
      it { is_expected.to have_key(:message) }
      it { is_expected.to have_key(:warning) }
      it { is_expected.to have_key(:hint) }
    end

    describe "validations" do
      it { is_expected.to validate_presence_of(:name) }
      it { is_expected.to allow_value("article").for(:name) }
      it { is_expected.to_not allow_value("Article Element").for(:name) }
    end

    describe "#blank?" do
      subject { definition.blank? }

      context "with name given" do
        let(:definition) { described_class.new(name: "article") }

        it { is_expected.to be(false) }
      end

      context "without name given" do
        let(:definition) { described_class.new }

        it { is_expected.to be(true) }
      end
    end

    describe ".all" do
      # skip memoization
      before { ElementDefinition.instance_variable_set(:@definitions, nil) }

      subject { ElementDefinition.all }

      it "should return all element definitions" do
        is_expected.to be_instance_of(Array)
        expect(subject.map(&:name)).to eq([
          "header",
          "headline",
          "article",
          "text",
          "search",
          "news",
          "download",
          "bild",
          "contactform",
          "all_you_can_eat",
          "erb_element",
          "tinymce_custom",
          "slide",
          "slider",
          "gallery",
          "gallery_picture",
          "right_column",
          "left_column",
          "erb_cell",
          "menu",
          "old",
          "element_with_ingredient_groups",
          "element_with_warning",
          "element_with_url"
        ])
      end
    end

    describe ".add" do
      it "adds a definition to all definitions" do
        ElementDefinition.add({"name" => "foo"})
        expect(ElementDefinition.all.map(&:name)).to include("foo")
      end

      it "adds a array of definitions to all definitions" do
        ElementDefinition.add([{"name" => "foo"}, {"name" => "bar"}])
        expect(ElementDefinition.all.map(&:name)).to include("foo", "bar")
      end
    end

    describe ".get" do
      it "should return the element definition found by given name" do
        expect(ElementDefinition.get("Article").name).to eq("article")
      end
    end

    describe ".reset!" do
      it "sets @definitions to nil" do
        ElementDefinition.all
        ElementDefinition.reset!
        expect(ElementDefinition.instance_variable_get(:@definitions)).to be_nil
      end
    end
  end
end
