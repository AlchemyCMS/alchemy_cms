# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::MainNavigation::Menu, type: :component, silence_deprecations: true do
  let(:first) do
    Alchemy::Configurations::MenuItem.new(name: "first", title: "First", position: 1, url: -> { alchemy.admin_pages_path })
  end

  let(:between) do
    Alchemy::Configurations::MenuItem.new(name: "between", title: "Between", position: 4.1, url: -> { alchemy.admin_languages_path })
  end

  let(:last) do
    Alchemy::Configurations::MenuItem.new(name: "last", title: "Last", position: 5, url: -> { alchemy.admin_sites_path })
  end

  let(:unpositioned) do
    Alchemy::Configurations::MenuItem.new(name: "unpositioned", title: "Unpositioned", url: -> { alchemy.admin_tags_path })
  end

  before do
    vc_test_view_context.class.include Alchemy::Admin::BaseHelper
    stub_alchemy_config(menu: [unpositioned, last, between, first])
  end

  it "renders the entries sorted by position with unpositioned entries last" do
    render_inline(described_class.new)
    expect(page.all("#main_navi alchemy-main-navi-entry label").map(&:text)).to eq(%w[First Between Last Unpositioned])
  end

  describe "#items" do
    it "returns the menu items sorted by position with unpositioned entries last" do
      expect(described_class.new.items).to eq([first, between, last, unpositioned])
    end

    context "with entries without a position" do
      let(:languages) do
        Alchemy::Configurations::MenuItem.new(name: "languages", title: "Languages", position: 4, url: -> { alchemy.admin_languages_path })
      end

      let(:sites) do
        Alchemy::Configurations::MenuItem.new(name: "sites", title: "Sites", position: 5, url: -> { alchemy.admin_sites_path })
      end

      let(:inserted) do
        Alchemy::Configurations::MenuItem.new(name: "inserted", title: "Inserted", url: -> { alchemy.admin_nodes_path })
      end

      let(:users) do
        Alchemy::Configurations::MenuItem.new(name: "users", title: "Users", position: 4.1, url: -> { alchemy.admin_tags_path })
      end

      before do
        stub_alchemy_config(menu: [languages, inserted, sites, unpositioned, users])
      end

      it "lists inserted entries after the positioned entry preceding them and appended entries last" do
        expect(described_class.new.items).to eq([languages, inserted, users, sites, unpositioned])
      end
    end
  end
end
