# frozen_string_literal: true

require "rails_helper"

module Alchemy
  class ModulesTestController < ApplicationController
    include Modules
  end

  describe Modules do
    let(:controller) { ModulesTestController.new }

    before do
      stub_alchemy_config(menu: Alchemy::Configurations::Main.new.menu)
    end

    describe ".register_module" do
      it "is deprecated" do
        expect(Alchemy::Deprecation).to receive(:warn)
        Modules.register_module(name: "module", navigation: {controller: "/admin/events", action: "index"})
      end
    end

    describe ".alchemy_modules" do
      it "is deprecated" do
        expect(Alchemy::Deprecation).to receive(:warn)
        Modules.alchemy_modules
      end
    end

    describe "#alchemy_modules" do
      it "is deprecated" do
        expect(Alchemy::Deprecation).to receive(:warn)
        controller.alchemy_modules
      end
    end

    describe "#module_definition_for" do
      it "is deprecated" do
        expect(Alchemy::Deprecation).to receive(:warn)
        controller.module_definition_for("dashboard")
      end

      it "is deprecated when looking up by controller and action" do
        expect(Alchemy::Deprecation).to receive(:warn)
        controller.module_definition_for(controller: "admin/events", action: "index")
      end

      it "is deprecated when called with something else" do
        expect(Alchemy::Deprecation).to receive(:warn)
        expect { controller.module_definition_for(1) }.to raise_error(ArgumentError)
      end
    end
  end
end
