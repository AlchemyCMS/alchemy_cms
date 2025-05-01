# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::HtmlView, type: :component do
  let(:ingredient) { Alchemy::Ingredients::Html.new(value: '<script>alert("hacked");</script>') }

  context "without value" do
    let(:ingredient) { Alchemy::Ingredients::Html.new(value: nil) }

    it "renders nothing" do
      render_inline described_class.new(ingredient)
      expect(page).to have_content("")
    end
  end

  context "with value" do
    it "renders the raw html source" do
      render_inline described_class.new(ingredient)
      expect(page).to have_selector("script")
    end
  end
end
