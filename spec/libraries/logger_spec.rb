# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Logger do
  let(:message) { "Something bad happened" }

  describe ".warn" do
    let(:caller_string) { "file.rb:14" }

    subject { Alchemy::Logger.warn(message, caller_string) }

    it { is_expected.to be_nil }

    it "uses Rails debug logger" do
      expect(Rails.logger).to receive(:debug) { message }
      subject
    end
  end

  describe "#log_warning" do
    let(:something) do
      Class.new do
        include Alchemy::Logger
      end
    end

    subject { something.new.log_warning(message) }

    before do
      expect_any_instance_of(something).to receive(:caller).with(1..1) { ["second"] }
    end

    it "delegates to Alchemy::Logger.warn class method with second line of callstack" do
      expect(Alchemy::Logger).to receive(:warn).with(message, ["second"])
      subject
    end
  end
end
