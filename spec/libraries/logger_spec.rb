# frozen_string_literal: true

require "rails_helper"

class Something
  include Alchemy::Logger
end

RSpec.describe Alchemy::Logger do
  let(:message) { "Something bad happened" }

  describe ".warn" do
    subject { Alchemy::Logger.warn(message) }

    context "when called with caller_string" do
      let(:caller_string) { "file.rb:14" }

      subject { Alchemy::Logger.warn(message, caller_string) }

      it "logs a deprecation warning about the second argument" do
        expect(Alchemy::Deprecation).to receive(:warn).with(/second argument is deprecated/)
        subject
      end
    end

    it { is_expected.to be_nil }

    it "uses Rails warn logger" do
      expect(Rails.logger).to receive(:warn).with(message)
      subject
    end

    it "adds a Rails log tag" do
      expect(Rails.logger).to receive(:tagged).with("alchemy").and_yield
      subject
    end
  end

  describe "#log_warning" do
    subject { Something.new.log_warning(message) }

    it "delegates to Alchemy::Logger.warn class method with second line of callstack", :silence_deprecations do
      expect(Alchemy::Logger).to receive(:warn).with(message)
      subject
    end
  end
end
