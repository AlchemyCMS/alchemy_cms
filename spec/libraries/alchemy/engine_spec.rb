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
        hide_const("Sprockets")
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

  describe ".watch_engine_files?" do
    subject { described_class.watch_engine_files? }

    context "in development, with the application inside the engine root" do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))
        allow(Rails.application).to receive(:root).and_return(described_class.root.join("spec/dummy"))
      end

      it { is_expected.to be(true) }
    end

    context "in development, with the application outside the engine root" do
      before do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))
        allow(Rails.application).to receive(:root).and_return(Pathname.new("/somewhere/else"))
      end

      it { is_expected.to be(false) }
    end

    context "outside of development" do
      before do
        allow(Rails.application).to receive(:root).and_return(described_class.root.join("spec/dummy"))
      end

      it { is_expected.to be(false) }
    end

    context "without rails_live_reload" do
      before do
        hide_const("RailsLiveReload")
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("development"))
        allow(Rails.application).to receive(:root).and_return(described_class.root.join("spec/dummy"))
      end

      it { is_expected.to be_falsey }
    end
  end

  # Two watchers over the same tree fight over one socket, and the gem offers no
  # hook to skip its own. It is disabled for the length of that one initializer
  # instead, so both halves have to stay paired.
  describe "toggling the gem's own watcher" do
    # The pair hands the previous setting over in an instance variable, so both
    # halves have to run against the engine instance they are bound to at boot.
    # The unbound class level collection carries a nil context.
    def initializer(name)
      described_class.instance.initializers.detect { _1.name == name }
    end

    around do |example|
      was_enabled = RailsLiveReload.config.enabled
      example.run
      RailsLiveReload.config.enabled = was_enabled
    end

    context "when Alchemy is developed from a checkout" do
      before do
        allow(described_class).to receive(:watch_engine_files?).and_return(true)
        RailsLiveReload.config.enabled = true
      end

      it "disables the gem's watcher before the gem starts it" do
        initializer("alchemy.disable_live_reload_watcher").run(Rails.application)

        expect(RailsLiveReload.config.enabled).to be(false)
      end

      it "restores the previous setting once the gem is past it" do
        initializer("alchemy.disable_live_reload_watcher").run(Rails.application)
        initializer("alchemy.restore_live_reload").run(Rails.application)

        expect(RailsLiveReload.config.enabled).to be(true)
      end
    end

    context "when Alchemy is installed as a gem" do
      before do
        allow(described_class).to receive(:watch_engine_files?).and_return(false)
        RailsLiveReload.config.enabled = true
      end

      it "leaves the gem's watcher alone" do
        initializer("alchemy.disable_live_reload_watcher").run(Rails.application)

        expect(RailsLiveReload.config.enabled).to be(true)
      end
    end

    it "disables the watcher after the gem's middleware and before its watcher" do
      expect(initializer("alchemy.disable_live_reload_watcher").after).to eq("rails_live_reload.middleware")
      expect(initializer("alchemy.disable_live_reload_watcher").before).to eq("rails_live_reload.watcher")
    end

    it "restores the setting after the gem's watcher and before its metrics" do
      expect(initializer("alchemy.restore_live_reload").after).to eq("rails_live_reload.watcher")
      expect(initializer("alchemy.restore_live_reload").before).to eq("rails_live_reload.configure_metrics")
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
      stub_alchemy_config(admin_importmaps: [additional_importmap])
    end

    it "adds additional importmap to admin imports" do
      initializer = Alchemy::Engine.initializers.find { _1.name == "alchemy.importmap" }
      expect(Alchemy.config.admin_js_imports).to receive(:add).with("additional_importmap")
      prepare_blocks = initializer.run(Rails.application)
      prepare_blocks.last.call
    end
  end
end
