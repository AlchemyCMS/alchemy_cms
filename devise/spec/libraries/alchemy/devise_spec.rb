require "rails_helper"

RSpec.describe Alchemy::Devise do
  describe ".config" do
    it "disables user impersonation by default" do
      expect(described_class::Configuration.new.user_impersonation).to be(false)
    end

    it "allows user impersonation to be enabled" do
      config = described_class::Configuration.new
      config.user_impersonation = true

      expect(config.user_impersonation).to be(true)
    end
  end

  describe ".layout" do
    it "delegates to Alchemy::Devise.config.layout" do
      Alchemy::Devise.deprecator.silenced do
        expect(Alchemy::Devise.layout).to eq(Alchemy::Devise.config.layout)
      end
    end

    it "is deprecated" do
      expect_any_instance_of(ActiveSupport::Deprecation).to receive(:warn).with(
        a_string_including("layout is deprecated"),
        an_instance_of(Array)
      )
      Alchemy::Devise.layout
    end
  end
end
