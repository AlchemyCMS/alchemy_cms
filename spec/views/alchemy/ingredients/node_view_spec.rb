# frozen_string_literal: true

require "rails_helper"

RSpec.describe "alchemy/ingredients/_node_view" do
  context "without node" do
    let(:ingredient) { Alchemy::Ingredients::Node.new }

    it "renders nothing" do
      render ingredient
      expect(rendered.strip).to be_empty
    end
  end

  context "with node" do
    let(:node) { build(:alchemy_node, url: "https://example.com") }
    let(:ingredient) { Alchemy::Ingredients::Node.new(node: node) }

    it "renders the node" do
      render ingredient
      expect(rendered).to have_selector("a[href='https://example.com']")
    end
  end
end
