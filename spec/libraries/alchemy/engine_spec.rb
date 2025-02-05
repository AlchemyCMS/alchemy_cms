# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Engine do
  describe "alchemy.admin_stylesheets" do
    it "includes custom css" do
      expect(Rails.application.config.assets.precompile).to include("alchemy/admin/custom.css")
    end
  end
end
