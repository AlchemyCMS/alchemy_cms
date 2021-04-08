# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::Node do
  it_behaves_like "an alchemy ingredient"

  let(:element) { build(:alchemy_element) }
  let(:node) { build(:alchemy_node) }

  let(:node_ingredient) do
    described_class.new(
      element: element,
      type: described_class.name,
      role: "menu",
      related_object: node,
    )
  end

  describe "node" do
    subject { node_ingredient.node }

    it { is_expected.to be_an(Alchemy::Node) }
  end

  describe "node=" do
    let(:node) { Alchemy::Node.new }

    subject { node_ingredient.node = node }

    it { is_expected.to be(node) }
  end
end
