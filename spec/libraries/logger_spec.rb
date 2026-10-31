# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Logger do
  let(:message) { "Something bad happened" }

  describe ".debug" do
    subject { described_class.debug(message) }

    it { is_expected.to be_nil }

    it "uses Rails debug logger" do
      expect(Rails.logger).to receive(:debug).with(message)
      subject
    end

    it "adds a Rails log tag" do
      expect(Rails.logger).to receive(:tagged).with("alchemy").and_yield
      subject
    end
  end

  describe ".error" do
    subject { described_class.error(message) }

    it { is_expected.to be_nil }

    it "uses Rails error logger" do
      expect(Rails.logger).to receive(:error).with("ERROR: #{message}")
      subject
    end

    it "adds a Rails log tag" do
      expect(Rails.logger).to receive(:tagged).with("alchemy").and_yield
      subject
    end
  end

  describe ".info" do
    subject { described_class.info(message) }

    it { is_expected.to be_nil }

    it "uses Rails info logger" do
      expect(Rails.logger).to receive(:info).with(message)
      subject
    end

    it "adds a Rails log tag" do
      expect(Rails.logger).to receive(:tagged).with("alchemy").and_yield
      subject
    end
  end

  describe ".warn" do
    subject { Alchemy::Logger.warn(message) }

    it { is_expected.to be_nil }

    it "uses Rails warn logger" do
      expect(Rails.logger).to receive(:warn).with("WARNING: #{message}")
      subject
    end

    it "adds a Rails log tag" do
      expect(Rails.logger).to receive(:tagged).with("alchemy").and_yield
      subject
    end
  end
end
