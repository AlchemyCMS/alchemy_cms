# frozen_string_literal: true

require "rails_helper"

describe Alchemy::LegacyPageUrl do
  let(:page) { build_stubbed(:alchemy_page) }

  it "is invalid with invalid URL characters" do
    expect(
      described_class.new(urlname: "<foo>{bar}", page: page)
    ).to be_invalid
  end

  it "is valid with correct urlname format" do
    expect(
      described_class.new(urlname: "my/0-work+is-nice_stuff", page: page)
    ).to be_valid
  end

  it "is valid with get parameters in urlname" do
    expect(
      described_class.new(urlname: "index.php?id=2", page: page)
    ).to be_valid
  end

  it "is valid with pound sign in urlname" do
    expect(
      described_class.new(urlname: "with#anchor", page: page)
    ).to be_valid
  end
end
