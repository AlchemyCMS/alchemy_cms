require "rails_helper"

RSpec.describe Alchemy do
  describe ".devise_modules" do
    it "delegates to Alchemy::Devise.config.devise_modules" do
      Alchemy::Devise.deprecator.silenced do
        expect(Alchemy.devise_modules).to eq(Alchemy::Devise.config.devise_modules)
      end
    end

    it "is deprecated" do
      expect_any_instance_of(ActiveSupport::Deprecation).to receive(:warn).with(
        a_string_including("devise_modules is deprecated"),
        an_instance_of(Array)
      )
      Alchemy.devise_modules
    end
  end
end
