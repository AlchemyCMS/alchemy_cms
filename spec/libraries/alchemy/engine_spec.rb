# frozen_string_literal: true

require "rails_helper"
require "sprockets"

RSpec.describe Alchemy::Engine do
  describe "alchemy.admin_stylesheets" do
    let(:initializer) do
      Alchemy::Engine.initializers.detect do
        _1.name == "alchemy.admin_stylesheets"
      end
    end

    context "when sprockets is not defined" do
      before do
        Object.send(:remove_const, :Sprockets)
      rescue NameError
      end

      it "does not add alchemy/admin/custom.css" do
        initializer.run(Rails.application)
        expect(Rails.application.config.assets.precompile).not_to include("alchemy/admin/custom.css")
      end
    end

    context "when sprockets is defined" do
      before do
        stub_const("Sprockets", Class.new)
      end

      it "includes alchemy/admin/custom.css" do
        initializer.run(Rails.application)
        expect(Rails.application.config.assets.precompile).to include("alchemy/admin/custom.css")
      end
    end
  end
end
