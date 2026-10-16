# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Configurations::MenuItem do
  let(:current_path) { "/admin/dashboard" }
  let(:current_params) { {controller: "alchemy/admin/dashboard", action: "index"} }

  let(:view_context) do
    double(
      "view context",
      alchemy: Alchemy::Engine.routes.url_helpers,
      main_app: Rails.application.routes.url_helpers,
      request: double("request", path: current_path, host: "example.com"),
      params: current_params
    )
  end

  describe "options" do
    subject(:item) do
      described_class.new(
        name: "pages",
        title: "modules.pages",
        engine_name: "alchemy",
        position: 4.1,
        icon: "pages",
        icon_style: "none",
        url: -> { alchemy.admin_pages_path },
        condition: -> { can?(:index, :alchemy_admin_pages) },
        match_path: %r{/admin/pages},
        children: [
          {title: "modules.layoutpages", url: -> { alchemy.admin_layoutpages_path }}
        ]
      )
    end

    it "reads the typed values" do
      expect(item.name).to eq("pages")
      expect(item.title).to eq("modules.pages")
      expect(item.engine_name).to eq("alchemy")
      expect(item.position).to eq(4.1)
      expect(item.icon).to eq("pages")
      expect(item.icon_style).to eq("none")
      expect(item.url).to be_a(Proc)
      expect(item.condition).to be_a(Proc)
      expect(item.match_path).to eq(%r{/admin/pages})
    end

    it "builds children as menu items" do
      expect(item.children.first).to be_a(described_class)
      expect(item.children.first.title).to eq("modules.layoutpages")
    end

    it "enables turbo by default" do
      expect(item.turbo).to be(true)
    end
  end

  describe "#path" do
    it "evaluates the url in the view context" do
      item = described_class.new(url: -> { alchemy.admin_pages_path })
      expect(item.path(view_context)).to eq("/admin/pages")
    end

    it "routes a legacy item through its engine" do
      item = described_class.new(engine_name: "alchemy", controller: "/alchemy/admin/pages", action: "index")
      expect(item.path(view_context)).to eq("/admin/pages")
    end

    it "routes a legacy item without engine through the main app" do
      item = described_class.new(controller: "/admin/events", action: "index")
      expect(item.path(view_context)).to eq("/admin/events")
    end

    it "is nil without url and controller" do
      expect(described_class.new.path(view_context)).to be_nil
    end
  end

  describe "#visible?" do
    it "evaluates the condition in the view context" do
      allow(view_context).to receive(:can?).with(:index, :alchemy_admin_pages).and_return(false)
      item = described_class.new(condition: -> { can?(:index, :alchemy_admin_pages) })
      expect(item.visible?(view_context)).to be(false)
    end

    it "checks the index permission of a legacy item's controller" do
      allow(view_context).to receive(:can?).with(:index, :admin_pictures).and_return(true)
      item = described_class.new(controller: "/admin/pictures", action: "index")
      expect(item.visible?(view_context)).to be(true)
    end

    it "is visible without condition and controller" do
      expect(described_class.new.visible?(view_context)).to be(true)
    end
  end

  describe "#current? and #active?" do
    let(:item) do
      described_class.new(
        url: -> { alchemy.admin_pages_path },
        children: [{url: -> { alchemy.admin_layoutpages_path }}]
      )
    end

    context "on the item's url" do
      let(:current_path) { "/admin/pages" }

      it { expect(item.current?(view_context)).to be(true) }
    end

    context "below the item's url" do
      let(:current_path) { "/admin/pages/1/edit" }

      it { expect(item.current?(view_context)).to be(true) }
    end

    context "on a path that only shares the item's url as prefix" do
      let(:current_path) { "/admin/pagesfoo" }

      it { expect(item.current?(view_context)).to be(false) }
    end

    context "on a child's url" do
      let(:current_path) { "/admin/layoutpages" }

      it "is active but not current" do
        expect(item.current?(view_context)).to be(false)
        expect(item.active?(view_context)).to be(true)
      end
    end

    context "elsewhere" do
      let(:current_path) { "/admin/languages" }

      it { expect(item.active?(view_context)).to be(false) }
    end

    context "with a url that has a query string" do
      let(:item) { described_class.new(url: -> { main_app.admin_events_path(filter: "x") }) }
      let(:current_path) { "/admin/events" }

      it { expect(item.current?(view_context)).to be(true) }
    end

    context "with an absolute url to this host" do
      let(:item) { described_class.new(url: -> { "http://example.com/admin/events" }) }
      let(:current_path) { "/admin/events/1" }

      it { expect(item.current?(view_context)).to be(true) }
    end

    context "with a url to another site" do
      let(:item) { described_class.new(url: -> { "https://guides.alchemy-cms.com" }) }

      it { expect(item.current?(view_context)).to be(false) }
    end

    context "with a url to another site sharing the request path" do
      let(:item) { described_class.new(url: -> { "https://other.example.org/admin/pages" }) }
      let(:current_path) { "/admin/pages/1/edit" }

      it { expect(item.current?(view_context)).to be(false) }
    end

    context "with a url without a path" do
      let(:item) { described_class.new(url: -> { "mailto:help@example.com" }) }

      it { expect(item.current?(view_context)).to be(false) }
    end

    context "with a url that is not a valid URI" do
      let(:item) { described_class.new(url: -> { "/admin/événements" }) }
      let(:current_path) { "/admin/événements" }

      it { expect(item.current?(view_context)).to be(false) }
    end

    context "with match_path" do
      let(:item) { described_class.new(url: -> { main_app.admin_events_path }, match_path: %r{\A/admin/(events|bookings)}) }
      let(:current_path) { "/admin/bookings/1" }

      it "matches the request path against it" do
        expect(item.current?(view_context)).to be(true)
      end
    end

    context "with a legacy item matching by nested controller" do
      let(:item) { described_class.new(controller: "/admin/events", action: "index", nested_controllers: ["admin/bookings"]) }
      let(:current_path) { "/admin/bookings" }
      let(:current_params) { {controller: "admin/bookings", action: "index"} }

      it { expect(item.current?(view_context)).to be(true) }
    end

    context "with a legacy nested entry" do
      let(:item) do
        described_class.new(controller: "/admin/events", action: "index", nested: [{controller: "/admin/locations", action: "edit"}])
      end
      let(:current_path) { "/admin/locations/1/edit" }
      let(:current_params) { {controller: "admin/locations", action: "edit"} }

      it { expect(item.current?(view_context)).to be(true) }
    end
  end

  describe "#matches_controller?" do
    let(:item) { described_class.new(controller: "/alchemy/admin/dashboard", action: "index") }

    it "matches controller and action, ignoring leading slashes" do
      expect(item.matches_controller?(controller: "alchemy/admin/dashboard", action: "index")).to be(true)
      expect(item.matches_controller?(controller: "/alchemy/admin/dashboard", action: "index")).to be(true)
    end

    it "does not match another action or controller" do
      expect(item.matches_controller?(controller: "alchemy/admin/dashboard", action: "show")).to be(false)
      expect(item.matches_controller?(controller: "alchemy/admin/pages", action: "index")).to be(false)
    end

    it "matches nested actions" do
      item = described_class.new(controller: "/alchemy/admin/dashboard", action: "index", nested_actions: ["show"])
      expect(item.matches_controller?(controller: "alchemy/admin/dashboard", action: "show")).to be(true)
    end

    it "matches nested controllers" do
      item = described_class.new(controller: "some/one", action: "index", nested_controllers: ["alchemy/admin/dashboard"])
      expect(item.matches_controller?(controller: "alchemy/admin/dashboard", action: "index")).to be(true)
    end

    it "never matches without a controller" do
      item = described_class.new(url: -> { alchemy.admin_dashboard_path })
      expect(item.matches_controller?(controller: "alchemy/admin/dashboard", action: "index")).to be(false)
    end
  end

  describe "#validate_controller_existence!" do
    it "passes for existing controllers" do
      item = described_class.new(
        name: "pages",
        controller: "/alchemy/admin/pages",
        action: "index",
        children: [{controller: "/alchemy/admin/layoutpages", action: "index"}]
      )
      expect { item.validate_controller_existence! }.not_to raise_error
    end

    it "passes for items linked by url" do
      item = described_class.new(name: "pages", url: -> { alchemy.admin_pages_path })
      expect { item.validate_controller_existence! }.not_to raise_error
    end

    it "raises an understandable error for a missing controller" do
      item = described_class.new(name: "bad_module_name", controller: "bad", action: "index")
      expect { item.validate_controller_existence! }.to raise_error(
        "Error in AlchemyCMS module definition: 'bad_module_name'. Could not find the matching controller class BadController for the specified controller: 'bad'"
      )
    end

    it "raises an understandable error for a missing child controller" do
      item = described_class.new(
        name: "bad_module_name",
        controller: "admin/events",
        action: "index",
        children: [{controller: "bad", action: "index"}]
      )
      expect { item.validate_controller_existence! }.to raise_error(
        "Error in AlchemyCMS module definition: 'bad_module_name'. Could not find the matching controller class BadController for the specified controller: 'bad'"
      )
    end
  end

  describe ".from_legacy_hash" do
    subject(:item) { described_class.from_legacy_hash(legacy_hash) }

    let(:legacy_hash) do
      {
        "name" => "events",
        "engine_name" => "my_engine",
        "position" => 8,
        "navigation" => {
          "name" => "Events",
          "controller" => "/admin/events",
          "action" => "index",
          "icon" => "calendar",
          "icon-style" => "none",
          "nested_actions" => ["edit"],
          "sub_navigation" => [
            {"name" => "Locations", "controller" => "/admin/locations", "action" => "index"}
          ],
          "nested" => [
            {"controller" => "/admin/events", "action" => "edit"}
          ]
        }
      }
    end

    it "flattens the navigation and renames its keys" do
      expect(item.name).to eq("events")
      expect(item.engine_name).to eq("my_engine")
      expect(item.position).to eq(8)
      expect(item.title).to eq("Events")
      expect(item.controller).to eq("/admin/events")
      expect(item.icon_style).to eq("none")
      expect(item.nested_actions.to_a).to eq(["edit"])
      expect(item.children.first.title).to eq("Locations")
      expect(item.nested.first.action).to eq("edit")
      expect(item.turbo).to be(true)
    end

    it "lets children inherit the engine name" do
      expect(item.children.first.engine_name).to eq("my_engine")
    end

    it "round-trips through to_legacy_hash" do
      expect(Alchemy::Modules.to_legacy_hash(item)).to eq(legacy_hash)
    end

    context "with a float position" do
      let(:legacy_hash) do
        {name: "users", engine_name: "alchemy", position: 4.1,
         navigation: {name: "modules.users", controller: "/alchemy/admin/users", action: "index", icon: "group"}}
      end

      it "keeps it" do
        expect(item.position).to eq(4.1)
      end
    end

    context "with symbol keys" do
      let(:legacy_hash) do
        {name: "events", navigation: {name: "Events", controller: "/admin/events", action: "index",
                                      sub_navigation: [{name: "Locations", controller: "/admin/locations", action: "index"}]}}
      end

      it "reads them" do
        expect(item.title).to eq("Events")
        expect(item.children.first.title).to eq("Locations")
      end
    end

    context "with indifferent access" do
      let(:legacy_hash) do
        {name: "events", navigation: {name: "Events", controller: "/admin/events", action: "index"}}.with_indifferent_access
      end

      it "reads it" do
        expect(item.title).to eq("Events")
      end
    end

    context "with turbolinks and turbo disabled" do
      let(:legacy_hash) do
        {name: "solidus", engine_name: "spree",
         navigation: {controller: "/spree/admin/orders", action: "index", data: {turbolinks: false, turbo: false}}}
      end

      it "disables turbo" do
        expect(item.turbo).to be(false)
      end
    end

    context "with turbo disabled as the string false" do
      let(:legacy_hash) do
        {"name" => "events", "navigation" => {"controller" => "/admin/events", "action" => "index", "data" => {"turbo" => "false"}}}
      end

      it "disables turbo" do
        expect(item.turbo).to be(false)
      end
    end

    context "with params and unknown keys" do
      let(:legacy_hash) do
        {
          "name" => "events",
          "custom" => "ignored",
          "navigation" => {
            "controller" => "/admin/events",
            "action" => "index",
            "params" => {"key" => "value"},
            "custom" => "ignored"
          }
        }
      end

      it "ignores them" do
        expect(item.controller).to eq("/admin/events")
      end
    end

    context "with url and condition callables" do
      let(:original) do
        described_class.new(
          name: "pages",
          title: "modules.pages",
          url: -> { alchemy.admin_pages_path },
          condition: -> { can?(:index, :alchemy_admin_pages) }
        )
      end
      let(:legacy_hash) { Alchemy::Modules.to_legacy_hash(original) }

      it "keeps the url" do
        expect(item.path(view_context)).to eq("/admin/pages")
      end

      it "keeps the condition" do
        expect(view_context).to receive(:can?).with(:index, :alchemy_admin_pages).and_return(false)
        expect(item.visible?(view_context)).to be(false)
      end
    end

    context "without navigation" do
      let(:legacy_hash) { {"name" => "broken"} }

      it "builds an item without navigation values" do
        expect(item.name).to eq("broken")
        expect(item.controller).to be_nil
      end
    end
  end
end
