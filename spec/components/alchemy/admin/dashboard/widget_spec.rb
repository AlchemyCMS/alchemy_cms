# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::Dashboard::Widget, type: :component do
  it "renders a turbo-frame with given id" do
    render_inline(described_class.new(id: "test-widget"))
    expect(page).to have_css(".widget turbo-frame#test-widget")
  end

  context "with style option" do
    it "renders the widget with the given style as CSS class" do
      render_inline(described_class.new(id: "styled-widget", style: "fancy"))
      expect(page).to have_css(".widget.fancy")
    end
  end

  context "with loading option" do
    it "renders the turbo-frame with the given loading attribute" do
      render_inline(described_class.new(id: "lazy-widget", loading: "lazy"))
      expect(page).to have_css("turbo-frame[loading='lazy']")
    end
  end

  context "with condition option" do
    it "renders the widget if condition is true" do
      render_inline(described_class.new(id: "conditional-widget", condition: -> { true }))
      expect(page).to have_css(".widget turbo-frame")
    end

    it "does not render the widget if condition is false" do
      render_inline(described_class.new(id: "conditional-widget", condition: -> { false }))
      expect(rendered_content).to be_empty
    end

    it "raises error if condition is not callable" do
      expect {
        described_class.new(id: "invalid-widget", condition: "not a proc")
      }.to raise_error(ArgumentError, ":condition argument must be a proc or lambda")
    end
  end
end
