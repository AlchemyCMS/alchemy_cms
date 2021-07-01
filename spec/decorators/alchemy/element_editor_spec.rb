# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::ElementEditor do
  let(:element) { Alchemy::Element.new }
  let(:element_editor) { described_class.new(element) }

  describe "#element" do
    it "returns element object" do
      expect(element_editor.element).to eq(element)
    end
  end

  describe "#contents" do
    let(:element) { create(:alchemy_element, :with_contents, name: "headline") }

    subject(:contents) { element_editor.contents }

    it "returns a ContentEditor instance for each content defined" do
      aggregate_failures do
        contents.each do |content|
          expect(content).to be_an(Alchemy::ContentEditor)
        end
      end
    end

    context "with a content defined but not existing yet" do
      before do
        expect(element).to receive(:definition).at_least(:once) do
          {
            name: "headline",
            contents: [
              {
                name: "headline",
                type: "EssenceText",
              },
              {
                name: "foo",
                type: "EssenceText",
              },
            ],
          }.with_indifferent_access
        end
      end

      it "creates the missing content" do
        expect { subject }.to change { element.contents.count }.by(1)
      end
    end
  end

  describe "#to_partial_path" do
    subject { element_editor.to_partial_path }

    it "returns the editor partial path" do
      is_expected.to eq("alchemy/admin/elements/element")
    end
  end

  describe "#css_classes" do
    subject { element_editor.css_classes }

    it "returns css classes for element editor partial" do
      is_expected.to include("element-editor")
    end

    context "with element is public" do
      let(:element) { build_stubbed(:alchemy_element, public: true) }

      it { is_expected.to include("visible") }
    end

    context "with element is not public" do
      let(:element) { build_stubbed(:alchemy_element, public: false) }

      it { is_expected.to include("hidden") }
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

    context "with element having content_definitions" do
      before do
        allow(element).to receive(:content_definitions) { [1] }
      end

      it { is_expected.to include("with-contents") }
    end

    context "with element not having content_definitions" do
      before do
        allow(element).to receive(:content_definitions) { [] }
      end

      it { is_expected.to include("without-contents") }
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

    context "for folded element" do
      before { allow(element).to receive(:folded?) { true } }

      it { is_expected.to eq(false) }
    end

    context "for expanded element" do
      before { allow(element).to receive(:folded?) { false } }

      context "and element having contents defined" do
        before { allow(element).to receive(:content_definitions) { [1] } }

        it { is_expected.to eq(true) }
      end

      context "and element having no contents defined" do
        before { allow(element).to receive(:content_definitions) { [] } }

        context "and element beeing taggable" do
          before { allow(element).to receive(:taggable?) { true } }

          it { is_expected.to eq(true) }
        end

        context "and element not beeing taggable" do
          before { allow(element).to receive(:taggable?) { false } }

          it { is_expected.to eq(false) }
        end

        context "but element has ingredients defined" do
          before {
            expect(element).to receive(:ingredient_definitions) {
              [{
                role: "headline", type: "Headline",
              }]
            }
          }

          it { is_expected.to eq(true) }
        end
      end
    end
  end

  describe "#respond_to?(:to_model)" do
    subject { element_editor.respond_to?(:to_model) }

    it { is_expected.to be(false) }
  end

  describe "deprecation_notice" do
    subject { element_editor.deprecation_notice }

    context "when element is not deprecated" do
      let(:element) { build(:alchemy_element, name: "article") }

      it { is_expected.to be_nil }
    end

    context "when element is deprecated" do
      let(:element) { build(:alchemy_element, name: "old") }

      context "with custom element translation" do
        it { is_expected.to eq("Old element is deprecated") }
      end

      context "without custom element translation" do
        let(:element) { build(:alchemy_element, name: "old_too") }

        before do
          allow(element).to receive(:definition) do
            {
              "name" => "old_too",
              "deprecated" => true,
            }
          end
        end

        it do
          is_expected.to eq(
            "WARNING! This element is deprecated and will be removed soon. " \
            "Please do not use it anymore."
          )
        end
      end

      context "with String as deprecation" do
        before do
          allow(element).to receive(:definition) do
            {
              "name" => "old",
              "deprecated" => "Foo baz widget",
            }
          end
        end

        it { is_expected.to eq("Foo baz widget") }
      end
    end
  end
end
