# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::MainNavigation::Menu, type: :component do
  let(:first) do
    Alchemy::Configurations::MenuItem.new(name: "first", title: "First", url: -> { alchemy.admin_pages_path })
  end

  let(:between) do
    Alchemy::Configurations::MenuItem.new(name: "between", title: "Between", url: -> { alchemy.admin_languages_path })
  end

  let(:last) do
    Alchemy::Configurations::MenuItem.new(name: "last", title: "Last", url: -> { alchemy.admin_sites_path })
  end

  before do
    vc_test_view_context.class.include Alchemy::Admin::BaseHelper
    stub_alchemy_config(menu: [first, between, last])
  end

  it "renders the entries in the order of the menu" do
    render_inline(described_class.new)
    expect(page.all("#main_navi alchemy-main-navi-entry label").map(&:text)).to eq(%w[First Between Last])
  end

  describe "#items" do
    it "returns the menu items in their order" do
      expect(described_class.new.items).to eq([first, between, last])
    end
  end
end
