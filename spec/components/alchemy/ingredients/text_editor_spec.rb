# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::TextEditor, type: :component do
  let(:element) { build_stubbed(:alchemy_element, name: "all_you_can_eat") }
  let(:ingredient) { Alchemy::Ingredients::Text.new(id: 1, role: "headline", value: "1234", element: element) }
  let(:ingredient_editor) { described_class.new(ingredient) }

  it_behaves_like "an alchemy ingredient editor"

  before do
    vc_test_view_context.class.include Alchemy::Admin::BaseHelper
    allow(ingredient).to receive(:settings) { settings }
    allow(vc_test_view_context).to receive(:can?).and_return(true)
  end

  let(:settings) { {} }

  subject(:rendered) do
    render_inline(ingredient_editor)
    page
  end

  context "with no input type set" do
    it "renders an input field of type number" do
      expect(rendered).to have_selector('input[type="text"]')
    end
  end

  context "with a different input type set" do
    let(:settings) do
      {
        input_type: "number"
      }
    end

    it "renders an input field of type number" do
      expect(rendered).to have_selector('input[type="number"]')
    end
  end

  context "with settings linkable set to true" do
    let(:settings) do
      {
        linkable: true
      }
    end

    it "renders link buttons" do
      expect(rendered).to have_selector("input[type='hidden'][name='#{ingredient_editor.form_field_name(:link)}']")
      expect(rendered).to have_selector("input[type='hidden'][name='#{ingredient_editor.form_field_name(:link_title)}']")
      expect(rendered).to have_selector("input[type='hidden'][name='#{ingredient_editor.form_field_name(:link_class_name)}']")
      expect(rendered).to have_selector("input[type='hidden'][name='#{ingredient_editor.form_field_name(:link_target)}']")
    end
  end

  context "with settings anchor set to true" do
    let(:settings) do
      {
        anchor: true
      }
    end

    it "renders anchor button" do
      expect(rendered).to have_selector(".edit-ingredient-anchor-link a")
    end
  end

  context "without edit permission" do
    before do
      allow(vc_test_view_context).to receive(:can?).and_return(false)
    end

    it "renders a readonly text input" do
      expect(rendered).to have_selector('input[type="text"][readonly]')
    end

    context "with settings anchor set to true" do
      let(:settings) { {anchor: true} }

      it "renders a disabled anchor button" do
        expect(rendered).to have_selector(".edit-ingredient-anchor-link a.disabled")
        expect(rendered).not_to have_selector(".edit-ingredient-anchor-link a[href]")
      end
    end
  end
end
