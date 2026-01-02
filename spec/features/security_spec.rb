# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Security.", type: :system do
  context "If user is not logged in" do
    it "should see login form" do
      visit "/admin/dashboard"
      expect(current_path).to eq(Alchemy.config.login_path)
    end
  end
end
