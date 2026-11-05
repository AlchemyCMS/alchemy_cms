# frozen_string_literal: true

require "rails_helper"
require "alchemy/upgrader"
require "prism"

RSpec.describe Alchemy::Upgrader::RegisterModuleRewriter do
  subject(:result) { described_class.new.rewrite(source) }

  let(:new_source) { result[0] }
  let(:rewritten_count) { result[1] }
  let(:manual_count) { result[2] }

  def menu_add_arguments(code)
    call = Prism.parse(code).value.statements.body.first
    Prism.parse("{#{call.arguments.slice}}").value.statements.body.first
  end

  context "with a register_module call inside to_prepare" do
    let(:source) do
      <<~RUBY
        Rails.application.config.to_prepare do
          Alchemy::Modules.register_module({
            name: "users",
            engine_name: "alchemy",
            position: 4.1,
            navigation: {
              name: "modules.users",
              controller: "/alchemy/admin/users",
              action: "index",
              icon: "group"
            }
          })

          Alchemy.config.signup_path = "/admin/signup"
        end
      RUBY
    end

    it "rewrites it to a guarded Alchemy.config.menu.insert at the position's index" do
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

          Alchemy.config.signup_path = "/admin/signup"
        end
      RUBY
      expect(rewritten_count).to eq(1)
      expect(manual_count).to eq(0)
    end

    it "generates valid Ruby" do
      expect { RubyVM::InstructionSequence.compile(new_source) }.not_to raise_error
    end
  end

  context "with a top level register_module call with keyword arguments" do
    let(:source) do
      <<~RUBY
        ::Alchemy::Modules.register_module(
          name: "events",
          position: 8,
          navigation: {
            name: "Events",
            controller: "/admin/events",
            action: "index",
            image: "events.png"
          }
        )
      RUBY
    end

    it "rewrites a position beyond the default menu to an unguarded Alchemy.config.menu.add" do
      expect(new_source).to eq(<<~RUBY)
        Alchemy.config.menu.add(
          name: "events",
          title: "Events",
          image: "events.png",
          controller: "/admin/events",
          action: "index"
        )
      RUBY
      expect(rewritten_count).to eq(1)
      expect(manual_count).to eq(0)
    end
  end

  context "with sub navigation, data, params and a heredoc inline image" do
    let(:source) do
      <<~RUBY
        Alchemy::Modules.register_module(
          name: "events",
          engine_name: "event_engine",
          navigation: {
            name: "modules.events",
            controller: "/admin/events",
            action: "index",
            params: {sort: "name"},
            data: {turbo: false},
            "icon-style": "line",
            nested_controllers: %w[admin/tickets],
            inline_image: <<~SVG,
              <svg width="16">
                <path d="M0 0"/>
              </svg>
            SVG
            sub_navigation: [
              {
                name: "modules.events",
                controller: "/admin/events",
                action: "index"
              },
              {
                name: "modules.locations",
                controller: "/admin/locations",
                action: "index",
                data: {turbo: false}
              }
            ]
          }
        )
      RUBY
    end

    it "rewrites all supported keys" do
      expect(rewritten_count).to eq(1)
      expect(Prism.parse(new_source).errors).to be_empty
      expect(new_source).not_to include("params")
      expect(new_source).to include(<<~RUBY.indent(2))
        children: [
          {title: "modules.events", engine_name: "event_engine", controller: "/admin/events", action: "index"},
          {title: "modules.locations", engine_name: "event_engine", turbo: false, controller: "/admin/locations", action: "index"}
        ]
      RUBY
    end

    it "keeps the values" do
      arguments = menu_add_arguments(new_source)
      values = arguments.elements.to_h { |assoc| [assoc.key.unescaped, assoc.value] }
      expect(values.keys).to eq(%w[name title engine_name icon_style inline_image turbo controller action nested_controllers children])
      expect(values["turbo"]).to be_a(Prism::FalseNode)
      expect(values["icon_style"].unescaped).to eq("line")
      expect(values["nested_controllers"].elements.map(&:unescaped)).to eq(["admin/tickets"])
      expect(values["inline_image"].unescaped).to eq(<<~SVG)
        <svg width="16">
          <path d="M0 0"/>
        </svg>
      SVG
    end
  end

  context "with a register_module call with a variable argument" do
    let(:source) do
      <<~RUBY
        alchemy_module = {name: "solidus", navigation: {name: "Shop"}}
        Alchemy::Modules.register_module(alchemy_module)
      RUBY
    end

    it "leaves it untouched" do
      expect(new_source).to eq(source)
      expect(rewritten_count).to eq(0)
      expect(manual_count).to eq(1)
    end
  end

  context "with an interpolated value" do
    let(:source) do
      <<~'RUBY'
        Alchemy::Modules.register_module(name: "events", navigation: {name: "#{prefix}.events"})
      RUBY
    end

    it "leaves it untouched" do
      expect(new_source).to eq(source)
      expect(manual_count).to eq(1)
    end
  end

  context "with a position that is not a number" do
    let(:source) do
      <<~RUBY
        Alchemy::Modules.register_module(name: "events", position: "5", navigation: {name: "Events"})
      RUBY
    end

    it "leaves it untouched" do
      expect(new_source).to eq(source)
      expect(manual_count).to eq(1)
    end
  end

  context "with a nameless register_module call inside to_prepare" do
    let(:source) do
      <<~RUBY
        Rails.application.config.to_prepare do
          Alchemy::Modules.register_module(navigation: {name: "Events", controller: "/admin/events", action: "index"})
        end
      RUBY
    end

    it "leaves it untouched" do
      expect(new_source).to eq(source)
      expect(rewritten_count).to eq(0)
      expect(manual_count).to eq(1)
    end
  end

  context "with a heredoc whose body follows the call" do
    let(:source) do
      <<~RUBY
        Alchemy::Modules.register_module(name: "events", navigation: {inline_image: <<~SVG})
          <svg/>
        SVG
      RUBY
    end

    it "leaves it untouched" do
      expect(new_source).to eq(source)
      expect(manual_count).to eq(1)
    end
  end

  context "with multibyte characters before the call" do
    let(:source) do
      <<~RUBY
        # Größe
        Alchemy::Modules.register_module(name: "events", navigation: {name: "Veranstaltungen ✓"})
      RUBY
    end

    it "splices the replacement at the right place" do
      expect(new_source).to eq(<<~RUBY)
        # Größe
        Alchemy.config.menu.add(
          name: "events",
          title: "Veranstaltungen ✓"
        )
      RUBY
    end
  end
end
