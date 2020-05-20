# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::EssenceNode, type: :model do
  it { is_expected.to belong_to(:ingredient_association).optional.class_name("Alchemy::Node") }

  describe "#ingredient" do
    let(:node) { build(:alchemy_node) }

    subject { described_class.new(node: node).ingredient }

    it { is_expected.to eq(node) }
  end

  describe "#preview_text" do
    let(:node) { build(:alchemy_node) }

    subject { described_class.new(node: node).preview_text }

    it { is_expected.to eq(node.name) }
  end
end
