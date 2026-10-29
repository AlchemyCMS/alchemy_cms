require "rails_helper"

RSpec.describe Alchemy::Devise::Engine do
  it "precompiles the user impersonation stylesheet" do
    expect(Rails.application.config.assets.precompile).to include("alchemy-user-impersonation.css")
  end
end
