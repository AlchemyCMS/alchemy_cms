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

  describe "alchemy.importmap" do
    let(:additional_importmap) do
      Alchemy::Configurations::Importmap.new(
        importmap_path: Rails.root.join("config/importmap.rb"),
        name: "additional_importmap",
        source_paths: [Rails.root.join("app/javascript")]
      )
    end

    before do
      stub_alchemy_config(:admin_importmaps, [additional_importmap])
    end

    it "adds additional importmap to admin imports" do
      initializer = Alchemy::Engine.initializers.find { _1.name == "alchemy.importmap" }
      expect(Alchemy.config.admin_js_imports).to receive(:add).with("additional_importmap")
      initializer.run(Rails.application)
    end
  end
end
