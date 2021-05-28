# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Ingredients::Node do
  it_behaves_like "an alchemy ingredient"

  let(:element) { build(:alchemy_element) }
  let(:node) { build_stubbed(:alchemy_node) }

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

  describe "#node_id" do
    subject { node_ingredient.node_id }

    it { is_expected.to be_an(Integer) }
  end

  describe "#node_id=" do
    let(:node) { Alchemy::Node.new(id: 111) }

    subject { node_ingredient.node_id = node.id }

    it { is_expected.to be(111) }
    it { expect(node_ingredient.related_object_type).to eq("Alchemy::Node") }
  end

  describe "preview_text" do
    subject { node_ingredient.preview_text }

    context "with a node" do
      let(:node) do
        Alchemy::Node.new(name: "A very long node name that would not fit")
      end

      it "returns first 30 characters of the nodes name" do
        is_expected.to eq("A very long node name that wou")
      end
    end

    context "with no node" do
      let(:node) { nil }

      it { is_expected.to eq("") }
    end
  end

  describe "value" do
    subject { node_ingredient.value }

    context "with node assigned" do
      it "returns node" do
        is_expected.to be(node)
      end
    end

    context "with no node assigned" do
      let(:node) { nil }

      it { is_expected.to be_nil }
    end
  end
end
