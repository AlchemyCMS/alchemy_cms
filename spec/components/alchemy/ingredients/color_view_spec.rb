# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::ColorView, type: :component do
  subject do
    render_inline described_class.new(ingredient)
    page
  end

  context "with a color as value" do
    let(:ingredient) { Alchemy::Ingredients::Color.new(value: "#fff") }

    it "renders the color" do
      is_expected.to have_content("#fff")
    end
  end

  context "with nil as value" do
    let(:ingredient) { Alchemy::Ingredients::Color.new(value: nil) }

    it "renders nothing" do
      is_expected.to have_content("")
    end
  end
end
