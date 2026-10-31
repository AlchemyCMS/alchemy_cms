# frozen_string_literal: true

require "rails_helper"
require "alchemy/upgrader"
require "prism"

RSpec.describe Alchemy::Upgrader::MenuPositionRewriter do
  subject(:result) { described_class.new.rewrite(source) }

  let(:new_source) { result[0] }
  let(:rewritten_count) { result[1] }
  let(:manual_count) { result[2] }

  context "with a position between the default entries" do
    let(:source) do
      <<~RUBY
        Rails.application.config.to_prepare do
          unless Alchemy.config.menu.any? { |item| item.name == "users" }
            Alchemy.config.menu.add(
              name: "users",
              title: "modules.users",
              engine_name: "alchemy",
              position: 4.1,
              icon: "group",
              controller: "/alchemy/admin/users",
              action: "index"
            )
          end
        end
      RUBY
    end

    it "rewrites it to an Alchemy.config.menu.insert at the position's index" do
      expect(new_source).to eq(<<~RUBY)
        Rails.application.config.to_prepare do
          unless Alchemy.config.menu.any? { |item| item.name == "users" }
            Alchemy.config.menu.insert(
              4,
              name: "users",
              title: "modules.users",
              engine_name: "alchemy",
              icon: "group",
              controller: "/alchemy/admin/users",
              action: "index"
            )
          end
        end
      RUBY
      expect(rewritten_count).to eq(1)
      expect(manual_count).to eq(0)
    end
  end

  context "with an inline call on the config block argument" do
    let(:source) do
      <<~RUBY
        Alchemy.configure do |config|
          config.menu.add(position: 1, name: "events", title: "Events")
        end
      RUBY
    end

    it "rewrites it to an inline insert" do
      expect(new_source).to eq(<<~RUBY)
        Alchemy.configure do |config|
          config.menu.insert(0, name: "events", title: "Events")
        end
      RUBY
    end
  end

  context "with a braced hash and the position last" do
    let(:source) do
      <<~RUBY
        config.menu.add({name: "events", position: 2})
      RUBY
    end

    it "removes the position and rewrites it to an insert" do
      expect(new_source).to eq(<<~RUBY)
        config.menu.insert(1, {name: "events"})
      RUBY
    end
  end

  context "with a position beyond the default entries" do
    let(:source) do
      <<~RUBY
        Alchemy.config.menu.add(
          name: "events",
          position: 8,
          title: "Events"
        )
      RUBY
    end

    it "only removes the position" do
      expect(new_source).to eq(<<~RUBY)
        Alchemy.config.menu.add(
          name: "events",
          title: "Events"
        )
      RUBY
      expect(rewritten_count).to eq(1)
    end
  end

  context "with multibyte characters before the call" do
    let(:source) do
      <<~RUBY
        # Veranstaltungen für Redakteure
        Alchemy.config.menu.add(name: "events", title: "Veranstaltungen", position: 3)
      RUBY
    end

    it "rewrites it" do
      expect(new_source).to eq(<<~RUBY)
        # Veranstaltungen für Redakteure
        Alchemy.config.menu.insert(2, name: "events", title: "Veranstaltungen")
      RUBY
    end
  end

  context "with a position that is not a literal number" do
    let(:source) do
      <<~RUBY
        Alchemy.config.menu.add(name: "events", position: EVENTS_POSITION)
      RUBY
    end

    it "leaves it untouched" do
      expect(new_source).to eq(source)
      expect(rewritten_count).to eq(0)
      expect(manual_count).to eq(1)
    end
  end

  context "with only a position" do
    let(:source) do
      <<~RUBY
        Alchemy.config.menu.add(position: 3)
      RUBY
    end

    it "leaves it untouched" do
      expect(new_source).to eq(source)
      expect(manual_count).to eq(1)
    end
  end

  context "with a menu.add call without a position" do
    let(:source) do
      <<~RUBY
        Alchemy.config.menu.add(name: "events", title: "Events")
      RUBY
    end

    it "leaves it untouched" do
      expect(new_source).to eq(source)
      expect(rewritten_count).to eq(0)
      expect(manual_count).to eq(0)
    end
  end

  context "with a position on another call" do
    let(:source) do
      <<~RUBY
        list.add(name: "events", position: 3)
      RUBY
    end

    it "leaves it untouched" do
      expect(new_source).to eq(source)
      expect(manual_count).to eq(0)
    end
  end

  context "with a syntax error" do
    let(:source) { "Alchemy.config.menu.add(position: 3" }

    it "leaves it untouched" do
      expect(new_source).to eq(source)
      expect(manual_count).to eq(1)
    end
  end
end
