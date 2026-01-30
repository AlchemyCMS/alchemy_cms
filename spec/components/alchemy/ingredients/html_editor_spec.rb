# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::HtmlEditor, type: :component do
  let(:element) { build_stubbed(:alchemy_element, name: "all_you_can_eat") }

  let(:ingredient) do
    stub_model(
      Alchemy::Ingredients::Html,
      element: element,
      role: "source"
    )
  end

  let(:html_editor) { described_class.new(ingredient) }
  let(:settings) { {} }

  subject do
    render_inline html_editor
    page
  end

  before do
    vc_test_view_context.class.include Alchemy::Admin::BaseHelper
  end

  it_behaves_like "an alchemy ingredient editor"

  it "renders a textarea" do
    is_expected.to have_selector("textarea[name='#{html_editor.form_field_name}']")
  end

  context "without edit permission" do
    before do
      allow(vc_test_view_context).to receive(:can?).and_return(false)
    end

    it "renders a readonly textarea" do
      is_expected.to have_selector("textarea[readonly]")
    end
  end
end
