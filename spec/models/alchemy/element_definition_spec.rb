# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe ElementDefinition do
    describe "#attributes" do
      let(:definition) { described_class.new(name: "standard") }

      subject { definition.attributes }

      it { is_expected.to have_key(:name) }
      it { is_expected.to have_key(:icon) }
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

      it { is_expected.to allow_value(true).for(:icon) }
      it { is_expected.to allow_value("article").for(:icon) }
      it { is_expected.to allow_value("Article_2").for(:icon) }
      it { is_expected.to allow_value("article2-line").for(:icon) }
      it { is_expected.to_not allow_value("Article Icon").for(:icon) }
      it { is_expected.to_not allow_value("article.svg").for(:icon) }
      it { is_expected.to_not allow_value("Article.png").for(:icon) }
    end

    it_behaves_like "having a hint" do
      let(:translation_key) { "article" }
      let(:translation_scope) { :element_hints }

      let(:subject) do
        described_class.new(name: "article", **hint)
      end
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

    describe "#deprecation_notice" do
      subject { definition.deprecation_notice }

      context "when element is not deprecated" do
        let(:definition) { described_class.new(name: "article") }

        it { is_expected.to be_nil }
      end

      context "when element is deprecated" do
        let(:definition) { described_class.new(name: "old", deprecated: true) }

        context "with custom element translation" do
          it { is_expected.to eq("Old element is deprecated") }
        end

        context "without custom element translation" do
          let(:definition) { described_class.new(name: "old_too", deprecated: true) }

          it do
            is_expected.to eq(
              "WARNING! This element is deprecated and will be removed soon. " \
              "Please do not use it anymore."
            )
          end
        end

        context "with String as deprecation" do
          let(:definition) { described_class.new(name: "old_string", deprecated: "Foo baz widget") }

          it { is_expected.to eq("Foo baz widget") }
        end
      end
    end

    describe "#icon_name" do
      subject(:icon_name) { definition.icon_name }

      context "with icon attribute being true" do
        let(:definition) { described_class.new(name: "article", icon: true) }

        it "returns the name attribute" do
          expect(icon_name).to eq("article")
        end
      end

      context "with icon attribute being a string" do
        let(:definition) { described_class.new(icon: "article-line") }

        it "returns the icon attribute" do
          expect(icon_name).to eq("article-line")
        end
      end

      context "without icon attribute" do
        let(:definition) { described_class.new }

        it "returns the default icon" do
          expect(icon_name).to eq("default")
        end
      end
    end

    describe "#icon_file_name" do
      subject(:icon_file_name) { definition.icon_file_name }

      let(:definition) { described_class.new }

      it "is a svg" do
        expect(icon_file_name).to match(/\.svg\z/)
      end
    end

    describe "#icon_file" do
      subject(:icon_file) { definition.icon_file }

      let(:definition) { described_class.new }

      it "is a svg file" do
        expect(icon_file).to match(/<svg/)
      end
    end

    describe "#ingredients" do
      let(:definition) { described_class.new }

      subject { definition.ingredients }

      it "returns ingredient definitions" do
        is_expected.to all is_a? IngredientDefinition
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
