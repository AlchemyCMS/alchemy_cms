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

    describe ".to_legacy_hash" do
      it "returns the nested, string keyed shape of the old module definitions" do
        item = Configurations::MenuItem.new(
          name: "languages",
          engine_name: "alchemy",
          position: 4,
          title: "modules.languages",
          controller: "/alchemy/admin/languages",
          action: "index",
          icon: "translate-2",
          icon_style: "none",
          children: [{title: "modules.languages", controller: "/alchemy/admin/languages", action: "index"}],
          nested: [{controller: "/alchemy/admin/languages", action: "edit"}]
        )

        expect(Modules.to_legacy_hash(item)).to eq(
          "name" => "languages",
          "engine_name" => "alchemy",
          "position" => 4,
          "navigation" => {
            "name" => "modules.languages",
            "controller" => "/alchemy/admin/languages",
            "action" => "index",
            "icon" => "translate-2",
            "icon-style" => "none",
            "sub_navigation" => [
              {"name" => "modules.languages", "controller" => "/alchemy/admin/languages", "action" => "index"}
            ],
            "nested" => [
              {"controller" => "/alchemy/admin/languages", "action" => "edit"}
            ]
          }
        )
      end

      it "emits the turbo data attribute when turbo is disabled" do
        item = Configurations::MenuItem.new(name: "events", controller: "/admin/events", action: "index", turbo: false)
        expect(Modules.to_legacy_hash(item)["navigation"]["data"]).to eq(turbo: false)
      end

      it "emits the url and condition callables" do
        url = -> { alchemy.admin_pages_path }
        condition = -> { can?(:index, :alchemy_admin_pages) }
        item = Configurations::MenuItem.new(name: "pages", url:, condition:)
        expect(Modules.to_legacy_hash(item)["navigation"]).to include("url" => url, "condition" => condition)
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
