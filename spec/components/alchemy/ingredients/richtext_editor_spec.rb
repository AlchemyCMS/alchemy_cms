# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::RichtextEditor, type: :component do
  let(:element) { build_stubbed(:alchemy_element, name: "all_you_can_eat") }
  let(:ingredient) { Alchemy::Ingredients::Richtext.new(role: "text", value: "<p>1234</p>", element: element) }
  let(:settings) { {} }

  before do
    vc_test_view_context.class.send :include, Alchemy::Admin::BaseHelper
    allow(ingredient).to receive(:settings) { settings }
    allow(vc_test_view_context).to receive(:can?).and_return(true)
  end

  subject do
    render_inline described_class.new(ingredient)
    page
  end

  it "renders a text area for tinymce" do
    is_expected.to have_selector("alchemy-tinymce textarea")
  end

  context "without custom configuration" do
    it "does not renders a custom configuration" do
      is_expected.to_not have_selector(".ingredient-editor.richtext script")
    end
  end

  context "with custom configuration" do
    let(:settings) { {tinymce: {plugin: "link", foo_bar: "foo-bar"}} }

    it "renders a custom configuration" do
      is_expected.to have_selector("alchemy-tinymce[plugin] textarea")
    end

    it "dasherize the attribute keys" do
      is_expected.to have_selector("alchemy-tinymce[foo-bar] textarea")
    end
  end

  context "without edit permission" do
    before do
      allow(vc_test_view_context).to receive(:can?).and_return(false)
    end

    it "renders tinymce with readonly attribute" do
      is_expected.to have_selector("alchemy-tinymce[readonly]")
    end
  end
end
