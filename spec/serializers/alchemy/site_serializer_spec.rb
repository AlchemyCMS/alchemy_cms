# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::SiteSerializer do
  subject { described_class.new(site).to_json }

  let(:site) { build_stubbed(:alchemy_site) }

  it "includes all attributes" do
    json = JSON.parse(subject)
    expect(json).to eq(
      "id" => site.id,
      "name" => site.name
    )
  end
end
