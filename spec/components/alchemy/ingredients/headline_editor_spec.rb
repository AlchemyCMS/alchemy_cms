# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::HeadlineEditor, type: :component do
  let(:element) { build_stubbed(:alchemy_element, name: "all_you_can_eat") }

  let(:ingredient) do
    stub_model(
      Alchemy::Ingredients::Headline,
      element: element,
      role: "headline"
    )
  end

  let(:headline_editor) { described_class.new(ingredient) }
  let(:settings) { {} }

  subject do
    render_inline headline_editor
    page
  end

  before do
    vc_test_view_context.class.include Alchemy::Admin::BaseHelper
    allow(ingredient).to receive(:settings) { settings }
    allow(vc_test_view_context).to receive(:can?).and_return(true)
  end

  it_behaves_like "an alchemy ingredient editor"

  it "renders a text input" do
    is_expected.to have_selector("input[type='text'][name='#{headline_editor.form_field_name}']")
  end

  it "renders a level select" do
    is_expected.to have_selector("select[name='#{headline_editor.form_field_name(:level)}']")
  end

  it "renders a tooltip" do
    is_expected.to have_selector("sl-tooltip[content='Level']")
  end

  context "and having many level options" do
    before do
      allow(headline_editor).to receive(:level_options) do
        [["H1", 1], ["H2", 2]]
      end
    end

    it { is_expected.to have_selector(".with-level-select") }
  end

  context "and having many size options" do
    before do
      allow(headline_editor).to receive(:size_options) do
        [[".h1", 1], [".h2", 2]]
      end
    end

    it { is_expected.to have_selector(".with-size-select") }
  end

  context "when only one level is given" do
    let(:settings) do
      {levels: [1]}
    end

    it "renders a disabled level select" do
      is_expected.to have_selector("select[disabled][name='#{headline_editor.form_field_name(:level)}']")
    end
  end

  it "does not render a size select" do
    is_expected.to_not have_selector("select[name='#{headline_editor.form_field_name(:size)}']")
  end

  context "when sizes are given" do
    let(:settings) do
      {sizes: [1, 2]}
    end

    it "renders a size select" do
      is_expected.to have_selector("select[name='#{headline_editor.form_field_name(:size)}']")
    end

    it "renders a tooltip" do
      is_expected.to have_selector("sl-tooltip[content='Size']")
    end
  end

  describe "#level_options" do
    subject { headline_editor.send(:level_options) }

    it { is_expected.to eq([["H1", 1], ["H2", 2], ["H3", 3], ["H4", 4], ["H5", 5], ["H6", 6]]) }

    context "when restricted through the ingredient settings" do
      before do
        expect(ingredient).to receive(:settings).and_return(levels: [2, 3])
      end

      it { is_expected.to eq([["H2", 2], ["H3", 3]]) }
    end
  end

  describe "#size_options" do
    subject { headline_editor.send(:size_options) }

    it { is_expected.to eq([]) }

    context "when enabled through the ingredient settings" do
      before do
        expect(ingredient).to receive(:settings).and_return(sizes: [3, 4])
      end

      it { is_expected.to eq([[".h3", 3], [".h4", 4]]) }
    end

    context "when two dimensional array" do
      before do
        expect(ingredient).to receive(:settings) do
          {
            sizes: [["XL", "text-xl"], ["L", "text-lg"]]
          }
        end
      end

      it { is_expected.to eq([["XL", "text-xl"], ["L", "text-lg"]]) }
    end
  end

  context "with settings anchor set to true" do
    let(:settings) do
      {
        anchor: true
      }
    end

    it "renders anchor link button" do
      is_expected.to have_selector(".edit-ingredient-anchor-link a")
    end
  end

  context "without edit permission" do
    before do
      allow(vc_test_view_context).to receive(:can?).and_return(false)
    end

    it "renders a readonly text input" do
      is_expected.to have_selector("input[type='text'][readonly]")
    end

    it "renders a disabled level select" do
      is_expected.to have_selector("select[disabled][name='#{headline_editor.form_field_name(:level)}']")
    end

    context "when sizes are given" do
      let(:settings) { {sizes: [1, 2]} }

      it "renders a disabled size select" do
        is_expected.to have_selector("select[disabled][name='#{headline_editor.form_field_name(:size)}']")
      end
    end
  end
end
