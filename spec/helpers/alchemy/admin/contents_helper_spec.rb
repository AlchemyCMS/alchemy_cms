# frozen_string_literal: true

require "rails_helper"

describe Alchemy::Admin::ContentsHelper do
  let(:element) { build_stubbed(:alchemy_element, name: "article") }
  let(:content) { mock_model("Content", essence_partial_name: "essence_text") }

  describe "content_label" do
    let(:content) do
      Alchemy::ContentEditor.new(build_stubbed(:alchemy_content, element: element))
    end

    subject { helper.content_label(content) }

    it "has for attribute set to content form field id" do
      is_expected.to have_selector("label[for=\"#{content.form_field_id}\"]")
    end
  end

  describe "render_content_name" do
    let(:content) do
      mock_model "Content",
        name: "intro",
        definition: { name: "intro", type: "EssenceText" },
        name_for_label: "Intro",
        has_validations?: false,
        deprecated?: false,
        has_warnings?: false
    end

    subject { helper.render_content_name(content) }

    it "returns the content name" do
      is_expected.to eq("Intro")
    end

    context "if content is nil" do
      let(:content) { nil }

      it "returns nil" do
        is_expected.to be_nil
      end
    end

    context "with missing definition" do
      let(:content) do
        mock_model "Content",
          name: "intro",
          definition: { },
          name_for_label: "Intro",
          has_validations?: false,
          deprecated?: false,
          has_warnings?: true,
          warnings: Alchemy.t(:content_definition_missing)
      end

      it "renders a warning with tooltip" do
        is_expected.to have_selector(".hint-with-icon .hint-bubble")
        is_expected.to have_content Alchemy.t(:content_definition_missing)
      end
    end

    context "when deprecated" do
      let(:content) do
        mock_model "Content",
          name: "intro",
          definition: { name: "intro", type: "EssenceText" },
          name_for_label: "Intro",
          has_validations?: false,
          deprecated?: true,
          has_warnings?: true,
          warnings: Alchemy.t(:content_deprecated)
      end

      it "renders a deprecation notice with tooltip" do
        is_expected.to have_selector(".hint-with-icon .hint-bubble")
        is_expected.to have_content Alchemy.t(:content_deprecated)
      end
    end

    context "with validations" do
      before { expect(content).to receive(:has_validations?).and_return(true) }

      it "show a validation indicator" do
        is_expected.to have_selector(".validation_indicator")
      end
    end
  end
end
