# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::SelectView, type: :component do
  let(:ingredient) { Alchemy::Ingredients::Select.new(value: "blue") }

  it "renders the ingredients value" do
    render_inline described_class.new(ingredient)
    expect(page).to have_content("blue")
  end

  context "without value" do
    let(:ingredient) { Alchemy::Ingredients::Select.new(value: "") }

    it "does not render" do
      render_inline described_class.new(ingredient)
      expect(page).to have_content("")
    end
  end

  context "with a value containing html" do
    let(:ingredient) { Alchemy::Ingredients::Select.new(value: "<script>alert('XSS')</script>") }

    it "escapes the value" do
      render_inline described_class.new(ingredient)
      expect(rendered_content).to include("&lt;script&gt;")
      expect(rendered_content).to_not include("<script>")
    end
  end
end
