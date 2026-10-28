require "rails_helper"

RSpec.describe Alchemy::Devise::Configuration do
  it "disables user impersonation by default" do
    expect(described_class.new.user_impersonation).to be(false)
  end

  it "allows user impersonation to be enabled" do
    config = described_class.new
    config.user_impersonation = true

    expect(config.user_impersonation).to be(true)
  end
end
