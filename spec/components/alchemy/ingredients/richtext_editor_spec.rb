# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::RichtextEditor, type: :component do
  let(:element) { build_stubbed(:alchemy_element, name: "all_you_can_eat") }
  let(:element_form) { ActionView::Helpers::FormBuilder.new(:element, element, vc_test_view_context, {}) }
  let(:ingredient) { Alchemy::Ingredients::Richtext.new(role: "text", value: "<p>1234</p>", element: element) }
  let(:settings) { {} }

  before do
    vc_test_view_context.class.send :include, Alchemy::Admin::BaseHelper
    allow(ingredient).to receive(:settings) { settings }
    render_inline described_class.new(ingredient, element_form:)
  end

  it "renders a text area for tinymce" do
    expect(page).to have_selector("alchemy-tinymce textarea")
  end

  context "without custom configuration" do
    it "does not renders a custom configuration" do
      expect(page).to_not have_selector(".ingredient-editor.richtext script")
    end
  end

  context "with custom configuration" do
    let(:settings) { {tinymce: {plugin: "link", foo_bar: "foo-bar"}} }

    it "renders a custom configuration" do
      expect(page).to have_selector("alchemy-tinymce[plugin] textarea")
    end

    it "dasherize the attribute keys" do
      expect(page).to have_selector("alchemy-tinymce[foo-bar] textarea")
    end
  end
end
