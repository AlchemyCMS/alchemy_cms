# frozen_string_literal: true

require "alchemy/configuration"

RSpec.describe Alchemy::Configuration do
  let(:configuration) do
    Class.new(described_class) do
      option :auto_logout_time, :integer, default: 30
    end.new
  end

  it "has a setter" do
    expect do
      configuration.auto_logout_time = 15
    end.to change { configuration.auto_logout_time }.from(30).to(15)
  end

  context "without a default value" do
    let(:configuration) do
      Class.new(described_class) do
        option :auto_logout_time, :integer
      end.new
    end

    it "defaults to nil" do
      expect(configuration.auto_logout_time).to be nil
    end
  end
end
