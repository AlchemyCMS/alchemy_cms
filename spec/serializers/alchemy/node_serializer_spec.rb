# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::NodeSerializer do
  subject { described_class.new(node).to_json }

  let(:node) { build_stubbed(:alchemy_node) }

  it "includes all attributes" do
    json = JSON.parse(subject)
    expect(json).to eq(
      "id" => node.id,
      "lft" => node.lft,
      "rgt" => node.rgt,
      "parent_id" => node.parent_id,
      "name" => node.name,
      "url" => node.url,
      "ancestors" => [],
    )
  end
end
