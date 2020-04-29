# frozen_string_literal: true

require "rails_helper"

describe "alchemy/essences/_essence_text_editor" do
  let(:essence) { Alchemy::EssenceText.new(body: "1234") }
  let(:content) { Alchemy::Content.new(essence: essence) }
  let(:settings) { {} }

  before do
    view.class.send :include, Alchemy::Admin::BaseHelper
    allow(view).to receive(:content_label).and_return("1e Zahl")
    allow(content).to receive(:settings) { settings }
    render partial: "alchemy/essences/essence_text_editor", locals: {
      essence_text_editor: Alchemy::ContentEditor.new(content),
    }
  end

  context "with no input type set" do
    it "renders an input field of type number" do
      expect(rendered).to have_selector('input[type="text"]')
    end
  end

  context "with a different input type set" do
    let(:settings) do
      {
        input_type: "number",
      }
    end

    it "renders an input field of type number" do
      expect(rendered).to have_selector('input[type="number"]')
    end
  end

  context "with settings linkable set to true" do
    let(:settings) do
      {
        linkable: true,
      }
    end

    it "renders link buttons" do
      expect(rendered).to have_selector('input[type="hidden"][name="contents[][link]"]')
      expect(rendered).to have_selector('input[type="hidden"][name="contents[][link_title]"]')
      expect(rendered).to have_selector('input[type="hidden"][name="contents[][link_class_name]"]')
      expect(rendered).to have_selector('input[type="hidden"][name="contents[][link_target]"]')
    end
  end
end
