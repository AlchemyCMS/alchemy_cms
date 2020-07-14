# frozen_string_literal: true

require "rails_helper"

module Alchemy
  class ModulesTestController < ApplicationController
    include Modules
  end

  describe Modules do
    let(:controller) { ModulesTestController.new }

    describe "#module_definition_for" do
      subject { controller.module_definition_for(params_or_name) }

      before do
        allow(controller).to receive(:alchemy_modules) { [dashboard_module] }
      end

      let(:dashboard_module) do
        {
          "engine_name" => "alchemy",
          "name" => "dashboard",
          "navigation" => {
            "controller" => "alchemy/admin/dashboard",
            "action" => "index",
          },
        }
      end

      context "with a string given as name" do
        let(:params_or_name) { "dashboard" }

        it "returns the module definition" do
          is_expected.to eq(dashboard_module)
        end
      end

      context "with a hash given as name" do
        let(:params_or_name) do
          {
            controller: "alchemy/admin/dashboard",
            action: "index",
          }
        end

        it "returns the module definition" do
          is_expected.to eq(dashboard_module)
        end

        context "with leading slash in controller name" do
          let(:params_or_name) do
            {
              controller: "/alchemy/admin/dashboard",
              action: "index",
            }
          end

          it "returns the module definition" do
            is_expected.to eq(dashboard_module)
          end
        end

        context "with controller name in subnavigation" do
          let(:dashboard_module) do
            {
              "engine_name" => "alchemy",
              "name" => "dashboard",
              "navigation" => {
                "controller" => "some/thing",
                "action" => "foo",
                "sub_navigation" => [
                  {
                    "controller" => "alchemy/admin/dashboard",
                    "action" => "index",
                  },
                ],
              },
            }
          end

          it "returns the module definition" do
            is_expected.to eq(dashboard_module)
          end
        end

        context "with controller name in nested" do
          let(:dashboard_module) do
            {
              "engine_name" => "alchemy",
              "name" => "dashboard",
              "navigation" => {
                "controller" => "some/thing",
                "action" => "foo",
                "nested" => [
                  {
                    "controller" => "alchemy/admin/dashboard",
                    "action" => "index",
                  },
                ],
              },
            }
          end

          it "returns the module definition" do
            is_expected.to eq(dashboard_module)
          end
        end
      end

      context "with nil given as name" do
        let(:params_or_name) { nil }

        it do
          expect { subject }.to raise_error(ArgumentError)
        end
      end
    end

    describe ".register_module" do
      let(:alchemy_module) do
        {
          "name" => "module",
          "navigation" => {
            "controller" => "register_module_dummy",
            "action" => "index",
          },
        }
      end

      let(:bad_alchemy_module_a) do
        {
          "name" => "bad_module_a",
          "navigation" => {
            "controller" => "bad_module",
            "action" => "index",
          },
        }
      end

      let(:bad_alchemy_module_b) do
        {
          "name" => "bad_module_b",
          "navigation" => {
            "controller" => "register_module_dummy",
            "action" => "index",
            "sub_navigation" => [{
              "controller" => "bad_module",
              "action" => "index",
            }],
          },
        }
      end

      it "registers a module definition into global list of modules" do
        class ::RegisterModuleDummyController
          ### mock the existence of the controller
        end

        Modules.register_module(alchemy_module)
        expect(Modules.alchemy_modules).to include(alchemy_module)
      end

      it "fails to register a module when a matching navigation controller cannot be found" do
        expect { Modules.register_module(bad_alchemy_module_a) }.to raise_error(NameError)
      end

      it "fails to register a module when a matching sub_navigation controller cannot be found" do
        expect { Modules.register_module(bad_alchemy_module_b) }.to raise_error(NameError)
      end
    end
  end
end
