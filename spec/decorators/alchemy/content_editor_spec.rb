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
    it "includes content_editor class" do
      expect(content_editor.css_classes).to include("content_editor")
    end

    it "includes essence partial class" do
      expect(content_editor.css_classes).to include(content_editor.essence_partial_name)
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
end
