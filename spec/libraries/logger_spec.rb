# frozen_string_literal: true

require "rails_helper"

class Something
  include Alchemy::Logger
end

RSpec.describe Alchemy::Logger do
  let(:message) { "Something bad happened" }

  describe ".warn" do
    let(:caller_string) { "file.rb:14" }

    subject { Alchemy::Logger.warn(message, caller_string) }

    it { is_expected.to be_nil }

    it "uses Rails warn logger" do
      expect(Rails.logger).to receive(:warn).with(message)
      subject
    end
  end

  describe "#log_warning" do
    subject { Something.new.log_warning(message) }

    before do
      expect_any_instance_of(Something).to receive(:caller).with(1..1) { ["second"] }
    end

    it "delegates to Alchemy::Logger.warn class method with second line of callstack" do
      expect(Alchemy::Logger).to receive(:warn).with(message, ["second"])
      subject
    end
  end
end
