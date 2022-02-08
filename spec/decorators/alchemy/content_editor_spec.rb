# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::ContentEditor do
  let(:essence) { Alchemy::EssenceText.new }
  let(:content) { Alchemy::Content.new(id: 1, essence: essence) }
  let(:content_editor) { described_class.new(content) }

  describe "#content" do
    it "returns content object" do
      expect(content_editor.content).to eq(content)
    end
  end

  describe "#css_classes" do
    subject { content_editor.css_classes }

    it "includes content_editor class" do
      is_expected.to include("content_editor")
    end

    it "includes essence partial class" do
      is_expected.to include(content_editor.essence_partial_name)
    end

    context "when deprecated" do
      before do
        expect(content).to receive(:deprecated?) { true }
      end

      it "includes deprecated" do
        is_expected.to include("deprecated")
      end
    end
  end

  describe "#data_attributes" do
    it "includes content_id" do
      expect(content_editor.data_attributes[:content_id]).to eq(content_editor.id)
    end

    it "includes content_name" do
      expect(content_editor.data_attributes[:content_name]).to eq(content_editor.name)
    end
  end

  describe "#to_partial_path" do
    subject { content_editor.to_partial_path }

    it "returns the editor partial path" do
      is_expected.to eq("alchemy/essences/essence_text_editor")
    end
  end

  describe "#form_field_name" do
    it "returns a name value for form fields with ingredient as default" do
      expect(content_editor.form_field_name).to eq("contents[1][ingredient]")
    end

    context "with a essence column given" do
      it "returns a name value for form fields for that column" do
        expect(content_editor.form_field_name(:link_title)).to eq("contents[1][link_title]")
      end
    end
  end

  describe "#form_field_id" do
    it "returns a id value for form fields with ingredient as default" do
      expect(content_editor.form_field_id).to eq("contents_1_ingredient")
    end

    context "with a essence column given" do
      it "returns a id value for form fields for that column" do
        expect(content_editor.form_field_id(:link_title)).to eq("contents_1_link_title")
      end
    end
  end

  describe "#respond_to?(:to_model)" do
    subject { content_editor.respond_to?(:to_model) }

    it { is_expected.to be(false) }
  end

  describe "#has_warnings?" do
    subject { content_editor.has_warnings? }

    context "when content is not deprecated" do
      let(:content) { build(:alchemy_content) }

      it { is_expected.to be(false) }
    end

    context "when content is deprecated" do
      let(:content) do
        mock_model("Content", definition: { deprecated: true }, deprecated?: true)
      end

      it { is_expected.to be(true) }
    end

    context "when content is missing its definition" do
      let(:content) do
        mock_model("Content", definition: {})
      end

      it { is_expected.to be(true) }
    end
  end

  describe "#warnings" do
    subject { content_editor.warnings }

    context "when content has no warnings" do
      let(:content) { build(:alchemy_content) }

      it { is_expected.to be_nil }
    end

    context "when content is missing its definition" do
      let(:content) do
        mock_model("Content", name: "foo", definition: {})
      end

      it { is_expected.to eq Alchemy.t(:content_definition_missing) }

      it "logs a warning" do
        expect(Alchemy::Logger).to receive(:warn)
        subject
      end
    end

    context "when content is deprecated" do
      let(:content) do
        mock_model("Content",
          name: "foo",
          definition: { "name" => "foo", "deprecated" => "Deprecated" },
          deprecated?: true)
      end

      it "returns a deprecation notice" do
        is_expected.to eq("Deprecated")
      end
    end
  end

  describe "#deprecation_notice" do
    subject { content_editor.deprecation_notice }

    context "when content is not deprecated" do
      let(:content) { build(:alchemy_content) }

      it { is_expected.to be_nil }
    end

    context "when content is deprecated" do
      let(:element) { build(:alchemy_element, name: "all_you_can_eat") }
      let(:content) { build(:alchemy_content, name: "essence_html", element: element) }

      context "with custom content translation" do
        it { is_expected.to eq("Old content is deprecated") }
      end

      context "without custom content translation" do
        let(:content) { build(:alchemy_content, name: "old_too", element: element) }

        before do
          allow(content).to receive(:definition) do
            {
              "name" => "old_too",
              "deprecated" => true,
            }
          end
        end

        it do
          is_expected.to eq(
            "WARNING! This content is deprecated and will be removed soon. " \
            "Please do not use it anymore."
          )
        end
      end

      context "with String as deprecation" do
        before do
          allow(content).to receive(:definition) do
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
