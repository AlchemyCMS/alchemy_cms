# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::Resource::DatepickerFilter, type: :component do
  let(:name) { "starts_at_gteq" }
  let(:params) { {} }
  let(:label) { "Starts at later than " }
  let(:input_type) { :datetime }
  let(:component) do
    described_class.new(name:, label:, input_type:, params:)
  end

  before do
    render
  end

  subject(:render) do
    render_inline component
  end

  describe "#render" do
    it "renders a select input with the correct options" do
      expect(page).to have_selector('input[name="q[starts_at_gteq]"][form="resource_search"]')
      expect(page).to have_selector("label", text: "Starts at later than ")
      expect(page).to have_selector("alchemy-datepicker[input_type='datetime']")
    end

    context "if input_type is :date" do
      let(:input_type) { :date }

      it "renders a datepicker with the correct input type" do
        expect(page).to have_selector("alchemy-datepicker[input_type='date']")
      end
    end

    context "if input_type is :time" do
      let(:input_type) { :time }

      it "renders a datepicker with the correct input type" do
        expect(page).to have_selector("alchemy-datepicker[input_type='time']")
      end
    end

    context "if params are set" do
      let(:params) { {q: {starts_at_gteq: "2025-04-01"}.with_indifferent_access} }

      it "renders the params value in the input field" do
        expect(page).to have_selector('input[name="q[starts_at_gteq]"][value]')
        expect(page).to have_selector("alchemy-datepicker[input_type='datetime']")
      end
    end
  end
end
