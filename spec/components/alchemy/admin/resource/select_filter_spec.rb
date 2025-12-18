# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::Resource::SelectFilter, type: :component do
  let(:name) { "status" }
  let(:options) { [["Published", "published"], ["Draft", "draft"], ["Archived", "archived"]] }
  let(:resource_name) { "page" }
  let(:params) { {q: {status: "published"}.with_indifferent_access} }
  let(:label) { "Status" }
  let(:include_blank) { "All" }
  let(:component) do
    described_class.new(name:, resource_name:, include_blank:, label:, options:, params:)
  end

  before do
    render
  end

  subject(:render) do
    render_inline component
  end

  describe "#render" do
    it "renders a select input with the correct options" do
      expect(page).to have_selector('select[name="q[status]"]')
      expect(page).to have_selector("option[selected]", text: "Published")
      expect(page).to have_selector("option", text: "Draft")
      expect(page).to have_selector("option", text: "Archived")
    end

    context "when multiple is true" do
      let(:component) do
        described_class.new(
          name:,
          resource_name:,
          include_blank:,
          label:,
          options:,
          params:,
          multiple: true
        )
      end

      it "renders a select input that allows multiple selections" do
        expect(page).to have_selector("select[multiple]")
      end
    end
  end
end
