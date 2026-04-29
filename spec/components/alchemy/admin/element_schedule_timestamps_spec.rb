# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::ElementScheduleTimestamps, type: :component do
  let(:element) { build_stubbed(:alchemy_element) }
  let(:component) { described_class.new(element:) }

  it "renders a public_on field with label" do
    render_inline component
    expect(page).to have_css("label[for='element_public_on']", text: Alchemy::Element.human_attribute_name(:public_on))
    expect(page).to have_css("input[name='element[public_on]'][type='datetime-local']")
  end

  it "renders a public_until field with label" do
    render_inline component
    expect(page).to have_css("label[for='element_public_until']", text: Alchemy::Element.human_attribute_name(:public_until))
    expect(page).to have_css("input[name='element[public_until]'][type='datetime-local']")
  end

  context "without errors" do
    it "does not render error messages" do
      render_inline component
      expect(page).not_to have_css("span.error")
    end
  end

  context "with errors on public_on" do
    before do
      element.errors.add(:public_on, "is invalid")
    end

    it "renders the error message" do
      render_inline component
      expect(page).to have_css("span.error", text: "is invalid")
    end
  end

  context "with errors on public_until" do
    before do
      element.errors.add(:public_until, "must be after public on")
    end

    it "renders the error message" do
      render_inline component
      expect(page).to have_css("span.error", text: "must be after public on")
    end
  end
end
