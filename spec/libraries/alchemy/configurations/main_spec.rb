# frozen_string_literal: true

require "rails_helper"
require "alchemy/configurations/main"

class MyCustomUser
end

RSpec.describe Alchemy::Configurations::Main do
  subject(:configuration) { described_class.new }

  describe "#set_from_yaml" do
    let(:fixture_file) do
      Rails.root.join("..", "fixtures", "config.yml")
    end

    subject { described_class.new }

    before { subject.set_from_yaml(fixture_file) }

    it "has data from the yaml file" do
      expect(subject.auto_logout_time).to eq(20)
    end
  end

  describe "default values" do
    describe "#page_searchable_checkbox" do
      subject { configuration.show_page_searchable_checkbox }
      it { is_expected.to be false }
    end
  end

  describe ".admin_importmaps" do
    subject { described_class.new.admin_importmaps }

    it "returns a Set of admin importmaps" do
      is_expected.to be_a(Alchemy::Configuration::CollectionOption)
    end
  end

  describe ".user_class" do
    before do
      subject.user_class = "Alchemy::MyCustomUser"
    end

    it "raises error if user_class is not a String" do
      expect {
        subject.user_class = DummyUser
      }.to raise_error(Alchemy::Configuration::ConfigurationError)
    end

    it "returns user_class_name with :: prefix" do
      expect(subject.user_class_name).to eq("::Alchemy::MyCustomUser")
    end
  end

  describe ".user_class" do
    before do
      subject.user_class = "DummyUser"
    end

    context "and the custom User class exists" do
      it "returns the custom user class" do
        expect(subject.user_class).to be(::DummyUser)
      end
    end

    context "and the custom user class does not exist" do
      before do
        subject.user_class = "NoUser"
      end

      it "raises a NameError" do
        expect { subject.user_class }.to raise_exception(NameError)
      end
    end
  end

  describe "defaults" do
    it "has default value for preview_load_timeout" do
      expect(subject.preview_load_timeout).to eq(5)
    end

    it "has default value for user_class_primary_key" do
      expect(subject.user_class_primary_key).to eq(:id)
    end

    it "has default value for signup_path" do
      expect(subject.signup_path).to eq("/signup")
    end

    it "has default value for login_path" do
      expect(subject.login_path).to eq("/login")
    end

    it "has default value for logout_path" do
      expect(subject.logout_path).to eq("/logout")
    end

    it "has default value for logout_method" do
      expect(subject.logout_method).to eq("delete")
    end
  end

  describe "#menu" do
    subject(:menu) { described_class.new.menu }

    let(:view_context) { double("view context", alchemy: Alchemy::Engine.routes.url_helpers) }

    it "holds the core navigation entries" do
      expect(menu).to all(be_a(Alchemy::Configurations::MenuItem))
      expect(menu.map(&:name)).to eq(%w[dashboard pages menus languages sites tags archive])
    end

    it "keeps positions, titles and icons" do
      expect(menu.map { |item| [item.position, item.title, item.icon, item.icon_style] }).to eq([
        [1, "Home", "home-2", nil],
        [2, "modules.pages", "pages", nil],
        [3, "modules.menus", "menu-2", nil],
        [4, "modules.languages", "translate-2", "none"],
        [5, "modules.sites", "global", nil],
        [6, "modules.tags", "price-tag-3", nil],
        [7, "modules.library", "archive-drawer", nil]
      ])
    end

    it "links the core entries to their index pages" do
      expect(menu.map { |item| item.path(view_context) }).to eq(
        %w[/admin/dashboard /admin/pages /admin/nodes /admin/languages /admin/sites /admin/tags /admin/pictures]
      )
    end

    it "links the sub navigation entries" do
      expect(menu.flat_map { |item| item.children.map { |child| [child.title, child.path(view_context)] } }).to eq([
        ["modules.pages", "/admin/pages"],
        ["modules.layoutpages", "/admin/layoutpages"],
        ["modules.pictures", "/admin/pictures"],
        ["modules.attachments", "/admin/attachments"]
      ])
    end

    it "guards every entry with the index permission of its controller" do
      checked = []
      allow(view_context).to receive(:can?) { |*args| checked << args }
      menu.each { |item| [item, *item.children].each { |entry| entry.visible?(view_context) } }
      expect(checked).to eq([
        [:index, :alchemy_admin_dashboard],
        [:index, :alchemy_admin_pages], [:index, :alchemy_admin_pages], [:index, :alchemy_admin_layoutpages],
        [:index, :alchemy_admin_nodes],
        [:index, :alchemy_admin_languages],
        [:index, :alchemy_admin_sites],
        [:index, :alchemy_admin_tags],
        [:index, :alchemy_admin_pictures], [:index, :alchemy_admin_pictures], [:index, :alchemy_admin_attachments]
      ])
    end

    it "accepts new entries" do
      menu.add(name: "events", title: "Events", url: -> { main_app.admin_events_path })
      expect(menu.map(&:name)).to include("events")
    end

    it "does not share added entries between configurations" do
      menu.add(name: "events", title: "Events", url: -> { main_app.admin_events_path })
      expect(described_class.new.menu.map(&:name)).not_to include("events")
    end
  end
end
