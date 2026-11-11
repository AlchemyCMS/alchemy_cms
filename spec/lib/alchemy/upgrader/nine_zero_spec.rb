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

  describe "#migrate_ingredient_editor_partials" do
    subject { upgrader.migrate_ingredient_editor_partials }

    around do |example|
      Dir.mktmpdir do |dir|
        @root = Pathname(dir)
        example.run
      end
    end

    let(:root) { @root }
    let(:partial) { root.join("app/views/alchemy/ingredients/_custom_editor.html.erb") }
    let(:component) { root.join("app/components/alchemy/ingredients/custom_editor.rb") }
    let(:template) { root.join("app/components/alchemy/ingredients/custom_editor.html.erb") }

    before do
      allow(Rails).to receive(:root).and_return(root)
      partial.dirname.mkpath
      partial.write("<%= custom_editor.value %>\n")
      allow(upgrader).to receive(:todo)
    end

    it "moves the partial into an editor component" do
      subject
      expect(partial).not_to exist
      expect(template.read).to eq("<%= ingredient.value %>\n")
      expect(component.read).to eq(<<~RUBY)
        # frozen_string_literal: true

        module Alchemy
          module Ingredients
            class CustomEditor < BaseEditor
            end
          end
        end
      RUBY
    end

    it "adds a todo to review the components" do
      subject
      expect(upgrader).to have_received(:todo).with(%r{app/components/alchemy/ingredients/custom_editor\.html\.erb}, kind_of(String)).once
    end

    context "if the template needs to be migrated by hand" do
      before { partial.write("<%= element_form.object %>\n") }

      it "adds a todo to migrate it by hand" do
        subject
        expect(upgrader).to have_received(:todo).with(/migrate these files.*custom_editor\.html\.erb/m, kind_of(String))
      end
    end

    context "if the component already exists" do
      before do
        component.dirname.mkpath
        component.write("# existing\n")
      end

      it "leaves the files untouched" do
        subject
        expect(partial).to exist
        expect(component.read).to eq("# existing\n")
        expect(template).not_to exist
      end

      it "adds a todo to migrate the partial by hand" do
        subject
        expect(upgrader).to have_received(:todo).with(%r{migrate these files.*app/views/alchemy/ingredients/_custom_editor\.html\.erb}m, kind_of(String)).once
      end
    end

    context "with a partial overriding a built-in editor" do
      let(:partial) { root.join("app/views/alchemy/ingredients/_text_editor.html.erb") }

      it "leaves it untouched and adds a todo" do
        subject
        expect(partial).to exist
        expect(root.join("app/components/alchemy/ingredients/text_editor.rb")).not_to exist
        expect(upgrader).to have_received(:todo).with(%r{migrate these files.*_text_editor\.html\.erb}m, kind_of(String)).once
      end
    end

    context "with a non ERB partial" do
      let(:partial) { root.join("app/views/alchemy/ingredients/_custom_editor.html.haml") }

      it "keeps the partial and generates an editor component" do
        subject
        expect(partial).to exist
        expect(component.read).to include("class CustomEditor < BaseEditor")
        expect(template).not_to exist
      end

      it "adds a todo to migrate the partial into the component" do
        subject
        expect(upgrader).to have_received(:todo).with(
          %r{migrate these files.*custom_editor\.rb.*_custom_editor\.html\.haml}m, kind_of(String)
        ).once
      end

      context "with a plural name" do
        let(:partial) { root.join("app/views/alchemy/ingredients/_settings_editor.html.haml") }

        it "does not generate a component" do
          subject
          expect(root.join("app/components/alchemy/ingredients")).not_to exist
          expect(upgrader).to have_received(:todo).with(%r{migrate these files.*_settings_editor\.html\.haml}m, kind_of(String)).once
        end
      end
    end

    context "without editor partials" do
      before { partial.delete }

      it "adds no todo" do
        subject
        expect(upgrader).not_to have_received(:todo)
      end
    end
  end

  describe "#remove_deprecated_columns" do
    subject { upgrader.remove_deprecated_columns }

    before do
      allow(upgrader).to receive(:desc)
    end

    context "without deprecated columns" do
      it "does nothing" do
        expect(upgrader).not_to receive(:yes?)
        expect(upgrader).not_to receive(:todo)
        subject
      end
    end

    context "with deprecated columns" do
      before do
        allow(ActiveRecord::Base.connection).to receive(:column_exists?).and_return(false)
        allow(ActiveRecord::Base.connection).to receive(:column_exists?).with(:alchemy_pages, "title").and_return(true)
      end

      context "when confirmed" do
        before { allow(upgrader).to receive(:yes?).and_return(true) }

        it "removes them" do
          expect(Alchemy::Tidy).to receive(:remove_deprecated_columns)
          subject
        end
      end

      context "when declined" do
        before { allow(upgrader).to receive(:yes?).and_return(false) }

        it "keeps them and adds a todo" do
          expect(Alchemy::Tidy).not_to receive(:remove_deprecated_columns)
          expect(upgrader).to receive(:todo).with(/alchemy:tidy:remove_deprecated_columns/, kind_of(String))
          subject
        end
      end
    end
  end
end
