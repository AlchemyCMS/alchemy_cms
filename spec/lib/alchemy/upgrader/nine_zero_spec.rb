# frozen_string_literal: true

require "rails_helper"
require "alchemy/upgrader"

RSpec.describe Alchemy::Upgrader::NineZero do
  let(:upgrader) { Alchemy::Upgrader["9.0"] }

  around do |example|
    Alchemy::Shell.silence!
    example.run
    Alchemy::Shell.verbose!
  end

  describe "#upgrade_menu_positions" do
    subject { upgrader.upgrade_menu_positions }

    around do |example|
      Dir.mktmpdir do |dir|
        @root = Pathname(dir)
        example.run
      end
    end

    let(:root) { @root }
    let(:initializer) { root.join("config/initializers/alchemy_events.rb") }

    before do
      allow(Rails).to receive(:root).and_return(root)
      initializer.dirname.mkpath
      initializer.write(initializer_content)
      allow(upgrader).to receive(:todo)
    end

    context "with a literal position" do
      let(:initializer_content) do
        <<~RUBY
          Alchemy.config.menu.add(name: "events", title: "Events", position: 4.5)
        RUBY
      end

      it "rewrites the initializer" do
        subject
        expect(initializer.read).to eq(<<~RUBY)
          Alchemy.config.menu.insert(4, name: "events", title: "Events")
        RUBY
      end

      it "adds a todo to review the rewritten files" do
        subject
        expect(upgrader).to have_received(:todo).with(%r{config/initializers/alchemy_events\.rb}, kind_of(String)).once
      end
    end

    context "with a non literal position" do
      let(:initializer_content) do
        <<~RUBY
          Alchemy.config.menu.add(name: "events", position: Events.position)
        RUBY
      end

      it "leaves the initializer untouched" do
        subject
        expect(initializer.read).to eq(initializer_content)
      end

      it "adds a todo to migrate the call manually" do
        subject
        expect(upgrader).to have_received(:todo).with(%r{config/initializers/alchemy_events\.rb.*config\.menu\.insert}m, kind_of(String)).once
      end
    end

    context "without positioned menu entries" do
      let(:initializer_content) { "Alchemy.config.menu.add(name: \"events\")\n" }

      it "adds no todo" do
        subject
        expect(upgrader).not_to have_received(:todo)
      end
    end

    context "when Prism is not available" do
      let(:initializer_content) do
        <<~RUBY
          Alchemy.config.menu.add(name: "events", position: 4.5)
        RUBY
      end

      before do
        allow(upgrader).to receive(:require).with("prism").and_raise(LoadError)
      end

      it "leaves the initializer untouched" do
        subject
        expect(initializer.read).to eq(initializer_content)
      end

      it "adds a todo to migrate the call manually" do
        subject
        expect(upgrader).to have_received(:todo).with(%r{config/initializers/alchemy_events\.rb.*config\.menu\.insert}m, kind_of(String)).once
      end
    end
  end
end
