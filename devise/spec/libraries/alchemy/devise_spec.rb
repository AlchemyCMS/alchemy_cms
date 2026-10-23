require "rails_helper"

RSpec.describe Alchemy::Devise do
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
