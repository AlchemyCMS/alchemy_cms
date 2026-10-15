# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::MainNavigation::SubNavigation, type: :component do
  subject(:render) { render_inline(described_class.new(item)) }

  let(:item) do
    Alchemy::Configurations::MenuItem.new(
      name: "archive",
      url: -> { alchemy.admin_pictures_path },
      children: [
        {title: "Pictures", url: -> { alchemy.admin_pictures_path }, condition: -> { can?(:index, :alchemy_admin_pictures) }},
        {title: "Attachments", url: -> { alchemy.admin_attachments_path }, condition: -> { can?(:index, :alchemy_admin_attachments) }}
      ]
    )
  end

  before do
    allow(vc_test_view_context).to receive(:can?).and_return(true)
  end

  it "renders a tab per child" do
    render
    expect(page).to have_css(".sub_navigation .subnavi_tab a[href='/admin/pictures']", text: "Pictures")
    expect(page).to have_css(".sub_navigation .subnavi_tab a[href='/admin/attachments']", text: "Attachments")
  end

  it "marks the child of the current path as active" do
    allow(vc_test_request).to receive(:path) { "/admin/attachments" }
    render
    expect(page).to have_css(".subnavi_tab.active", text: "Attachments")
    expect(page).not_to have_css(".subnavi_tab.active", text: "Pictures")
  end

  context "without permission for a child" do
    before do
      allow(vc_test_view_context).to receive(:can?).with(:index, :alchemy_admin_attachments).and_return(false)
    end

    it "does not render that child" do
      render
      expect(page).to have_css(".subnavi_tab", text: "Pictures")
      expect(page).not_to have_css(".subnavi_tab", text: "Attachments")
    end
  end

  context "with a legacy item from an engine" do
    let(:item) do
      Alchemy::Configurations::MenuItem.from_legacy_hash(
        name: "archive",
        engine_name: "alchemy",
        navigation: {
          controller: "/alchemy/admin/pictures",
          action: "index",
          sub_navigation: [{name: "Attachments", controller: "/alchemy/admin/attachments", action: "index"}]
        }
      )
    end

    it "routes the children through the parent's engine" do
      render
      expect(page).to have_css("a[href='/admin/attachments']", text: "Attachments")
    end
  end

  context "without children" do
    let(:item) do
      Alchemy::Configurations::MenuItem.new(name: "tags", url: -> { alchemy.admin_tags_path })
    end

    it "renders nothing" do
      render
      expect(page).not_to have_css(".sub_navigation")
    end
  end
end
