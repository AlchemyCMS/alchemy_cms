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
      end
    end
  end

  describe "#respond_to?(:to_model)" do
    subject { element_editor.respond_to?(:to_model) }

    it { is_expected.to be(false) }
  end
end
