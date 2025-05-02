# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::NodeView, type: :component do
  context "without node" do
    let(:ingredient) { Alchemy::Ingredients::Node.new }

    it "renders nothing" do
      render_inline described_class.new(ingredient)
      expect(page).to have_content("")
    end
  end

  context "with node" do
    let(:node) { build(:alchemy_node, url: "https://example.com") }
    let(:ingredient) { Alchemy::Ingredients::Node.new(node: node) }

    it "renders the node" do
      render_inline described_class.new(ingredient)
      expect(page).to have_selector("a[href='https://example.com']")
    end
  end
end
