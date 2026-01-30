# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::ElementEditor, type: :component do
  before do
    vc_test_view_context.class.include Alchemy::Admin::BaseHelper
  end

  let(:element) { Alchemy::Element.new }
  let(:element_editor) { described_class.new(element: element) }

  describe "#element" do
    it "returns element object" do
      expect(element_editor.element).to eq(element)
    end
  end

  describe "#ingredients" do
    let(:element) { create(:alchemy_element, :with_ingredients) }

    subject(:ingredients) { element_editor.ingredients }

    it "returns ingredient instances for each ingredient defined" do
      aggregate_failures do
        ingredients.each do |ingredient|
          expect(ingredient).to be_an(Alchemy::Ingredient)
        end
      end
    end

    context "with a ingredient defined but not existing yet" do
      let(:element) { create(:alchemy_element, name: "headline") }

      before do
        expect(element).to receive(:definition).at_least(:once) do
          Alchemy::ElementDefinition.new(
            name: "headline",
            ingredients: [
              {
                role: "headline",
                type: "Headline"
              }
            ]
          )
        end
      end

      it "creates the missing ingredient" do
        expect { subject }.to change { element.ingredients.count }.by(1)
      end
    end
  end

  describe "#css_classes" do
    subject { element_editor.css_classes }

    it "returns css classes for element editor partial" do
      is_expected.to include("element-editor")
    end

    context "with element is public" do
      let(:element) { build_stubbed(:alchemy_element, public: true) }

      it { is_expected.to_not include("element-hidden") }
    end

    context "with element is not public" do
      let(:element) { build_stubbed(:alchemy_element, public: false) }

      it { is_expected.to include("element-hidden") }
    end

    context "with element is folded" do
      let(:element) { build_stubbed(:alchemy_element, folded: true) }

      it { is_expected.to include("folded") }
    end

    context "with element is expanded" do
      let(:element) { build_stubbed(:alchemy_element, folded: false) }

      it { is_expected.to include("expanded") }
    end

    context "with element is taggable" do
      before do
        allow(element).to receive(:taggable?) { true }
      end

      it { is_expected.to include("taggable") }
    end

    context "with element is not taggable" do
      before do
        allow(element).to receive(:taggable?) { false }
      end

      it { is_expected.to include("not-taggable") }
    end

    context "with element having ingredient_definitions" do
      before do
        allow(element).to receive(:ingredient_definitions) { [1] }
      end

      it { is_expected.to include("with-ingredients") }
    end

    context "with element not having ingredient_definitions" do
      before do
        allow(element).to receive(:ingredient_definitions) { [] }
      end

      it { is_expected.to include("without-ingredients") }
    end

    context "with element having nestable_elements" do
      before do
        allow(element).to receive(:nestable_elements) { [1] }
      end

      it { is_expected.to include("nestable") }
    end

    context "with element not having nestable_elements" do
      before do
        allow(element).to receive(:nestable_elements) { [] }
      end

      it { is_expected.to include("not-nestable") }
    end

    context "with element being deprecated" do
      before do
        allow(element).to receive(:deprecated?) { true }
      end

      it { is_expected.to include("deprecated") }
    end
  end

  describe "#editable?" do
    subject { element_editor.editable? }

    context "for element having ingredients defined" do
      before { allow(element).to receive(:ingredient_definitions) { [1] } }

      it { is_expected.to eq(true) }
    end

    context "for element having no ingredients defined" do
      before { allow(element).to receive(:ingredient_definitions) { [] } }

      context "and element being taggable" do
        before { allow(element).to receive(:taggable?) { true } }

        it { is_expected.to eq(true) }
      end

      context "and element not being taggable" do
        before { allow(element).to receive(:taggable?) { false } }

        it { is_expected.to eq(false) }
      end
    end
  end

  describe "#ungrouped_ingredients" do
    let(:element) { create(:alchemy_element, :with_ingredients) }

    subject(:ungrouped) { element_editor.ungrouped_ingredients }

    it "returns ingredients without a group" do
      expect(ungrouped).to all(satisfy { |i| i.definition.group.nil? })
    end

    context "with grouped ingredients" do
      before do
        allow(element).to receive(:definition) do
          Alchemy::ElementDefinition.new(
            name: element.name,
            ingredients: [
              {role: "headline", type: "Text"},
              {role: "text", type: "Text", group: "content"}
            ]
          )
        end
      end

      it "excludes grouped ingredients" do
        expect(ungrouped.map(&:role)).to eq(["headline"])
      end
    end
  end

  describe "#grouped_ingredients" do
    let(:element) { create(:alchemy_element, name: "article") }

    before do
      allow(element).to receive(:definition) do
        Alchemy::ElementDefinition.new(
          name: "article",
          ingredients: [
            {role: "headline", type: "Text"},
            {role: "text", type: "Richtext", group: "content"},
            {role: "image", type: "Picture", group: "content"},
            {role: "caption", type: "Text", group: "metadata"}
          ]
        )
      end
    end

    subject(:grouped) { element_editor.grouped_ingredients }

    it "returns a hash of ingredients grouped by group name" do
      expect(grouped.keys).to match_array(["content", "metadata"])
    end

    it "groups ingredients correctly" do
      expect(grouped["content"].map(&:role)).to match_array(["text", "image"])
      expect(grouped["metadata"].map(&:role)).to eq(["caption"])
    end

    it "excludes ungrouped ingredients" do
      all_grouped_roles = grouped.values.flatten.map(&:role)
      expect(all_grouped_roles).not_to include("headline")
    end
  end

  describe "rendering" do
    let(:definition) do
      Alchemy::ElementDefinition.new(
        name: "with_message",
        message: "One nice message"
      )
    end

    before do
      allow(element).to receive(:definition) { definition }
    end

    context "with message given in element definition" do
      let(:element) { create(:alchemy_element, name: "with_message") }

      it "renders the message" do
        render_inline(described_class.new(element: element))
        expect(page).to have_css("alchemy-message", text: "One nice message")
      end

      context "that contains HTML" do
        let(:definition) do
          Alchemy::ElementDefinition.new(
            name: "with_message",
            message: "<h1>One nice message</h1>"
          )
        end

        it "renders the HTML message" do
          render_inline(described_class.new(element: element))
          expect(page).to have_css('alchemy-message[type="info"] h1', text: "One nice message")
        end
      end
    end

    context "with warning given in element definition" do
      let(:element) { create(:alchemy_element, name: "with_warning") }

      let(:definition) do
        Alchemy::ElementDefinition.new(
          name: "with_warning",
          warning: "One nice warning"
        )
      end

      it "renders the warning" do
        render_inline(described_class.new(element: element))
        expect(page).to have_css('alchemy-message[type="warning"]', text: "One nice warning")
      end

      context "that contains HTML" do
        let(:definition) do
          Alchemy::ElementDefinition.new(
            name: "with_warning",
            warning: "<h1>One nice warning</h1>"
          )
        end

        it "renders the HTML warning" do
          render_inline(described_class.new(element: element))
          expect(page).to have_css('alchemy-message[type="warning"] h1', text: "One nice warning")
        end
      end
    end

    context "with element beeing taggable" do
      let(:element) { create(:alchemy_element, name: "taggable") }

      let(:definition) do
        Alchemy::ElementDefinition.new(
          name: "taggable",
          taggable: true
        )
      end

      it "renders the tag autocomplete" do
        render_inline(described_class.new(element: element))
        expect(page).to have_selector("alchemy-tags-autocomplete")
      end

      context "but user cannot edit tags" do
        before do
          allow(vc_test_view_context).to receive(:cannot?) { true }
        end

        it "renders the tag autocomplete as disabled" do
          render_inline(described_class.new(element: element))
          expect(page).to have_selector("alchemy-tags-autocomplete input[disabled]")
        end
      end
    end
  end

  describe ".with_collection" do
    let(:elements) do
      [
        build_stubbed(:alchemy_element, id: 1, name: "header"),
        build_stubbed(:alchemy_element, id: 2, name: "header")
      ]
    end

    before do
      elements.each do |el|
        allow(el).to receive(:definition) do
          Alchemy::ElementDefinition.new(name: el.name)
        end
      end
    end

    it "renders all elements in the collection" do
      render_inline(described_class.with_collection(elements))

      expect(page).to have_css("alchemy-element-editor", count: 2)
    end
  end
end
