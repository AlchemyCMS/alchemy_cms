# frozen_string_literal: true

require "rails_helper"

describe Alchemy::Admin::NavigationHelper do
  let(:alchemy_module) do
    {
      "name" => "dashboard",
      "engine_name" => "alchemy",
      "navigation" => {
        "name" => "modules.dashboard",
        "controller" => "alchemy/admin/dashboard",
        "action" => "index",
        "icon" => "dashboard"
      }
    }
  end

  describe "#alchemy_main_navigation_entry" do
    before do
      allow(helper).to receive(:can?).and_return(true)
    end

    it "is deprecated" do
      expect(Alchemy::Deprecation).to receive(:warn)
      helper.alchemy_main_navigation_entry(alchemy_module)
    end
  end

  describe "#url_for_module" do
    it "is deprecated" do
      expect(Alchemy::Deprecation).to receive(:warn)
      helper.url_for_module(alchemy_module)
    end
  end

  describe "#sorted_alchemy_modules" do
    it "is deprecated" do
      expect(Alchemy::Deprecation).to receive(:warn)
      helper.sorted_alchemy_modules
    end
  end
end
