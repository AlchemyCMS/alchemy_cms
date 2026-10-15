# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Admin::MainNavigation::Entry, type: :component do
  subject(:render) { render_inline(described_class.new(item: item)) }

  let(:attributes) { {} }

  let(:item) do
    Alchemy::Configurations::MenuItem.new(
      {
        name: "pages",
        title: "Pages",
        url: -> { alchemy.admin_pages_path },
        condition: -> { can?(:index, :alchemy_admin_pages) }
      }.merge(attributes)
    )
  end

  before do
    vc_test_view_context.class.include Alchemy::Admin::BaseHelper
    allow(vc_test_view_context).to receive(:can?).and_return(true)
  end

  it "renders the entry linking to its url" do
    render
    expect(page).to have_css("alchemy-main-navi-entry.main_navi_entry > a[href='/admin/pages'] label", text: "Pages")
  end

  it "renders no data-turbo attribute" do
    render
    expect(page).not_to have_css("alchemy-main-navi-entry[data-turbo]")
  end

  it "renders the default icon" do
    render
    expect(page).to have_css('alchemy-icon[name="table"]')
  end

  context "with turbo disabled" do
    let(:attributes) { {turbo: false} }

    it "renders data-turbo false" do
      render
      expect(page).to have_css('alchemy-main-navi-entry[data-turbo="false"]')
    end
  end

  context "with an image" do
    let(:attributes) { {image: "alchemy/alchemy-logo.svg"} }

    it "renders the image" do
      render
      expect(page).to have_css("alchemy-main-navi-entry img[src*='alchemy-logo']")
    end
  end

  context "with an inline image" do
    let(:attributes) { {inline_image: '<svg class="inline-logo"></svg>'} }

    it "renders the inline image unescaped" do
      render
      expect(page).to have_css("alchemy-main-navi-entry svg.inline-logo")
    end
  end

  context "with an icon" do
    let(:attributes) { {icon: "translate-2", icon_style: "none"} }

    it "renders the icon with its style" do
      render
      expect(page).to have_css('alchemy-icon[name="translate-2"][icon-style="none"]')
    end
  end

  context "when the condition fails" do
    it "renders nothing" do
      expect(vc_test_view_context).to receive(:can?).with(:index, :alchemy_admin_pages).and_return(false)
      render
      expect(page).not_to have_css("alchemy-main-navi-entry")
    end
  end

  context "on a path below its url" do
    before { allow(vc_test_request).to receive(:path) { "/admin/pages/1/edit" } }

    it "is active" do
      render
      expect(page).to have_css("alchemy-main-navi-entry.active")
    end
  end

  context "elsewhere" do
    before { allow(vc_test_request).to receive(:path) { "/admin/dashboard" } }

    it "is not active" do
      render
      expect(page).not_to have_css("alchemy-main-navi-entry.active")
    end
  end

  context "with children" do
    let(:attributes) do
      {children: [{title: "Layoutpages", url: -> { alchemy.admin_layoutpages_path }}]}
    end

    it "renders the sub navigation" do
      render
      expect(page).to have_css("alchemy-main-navi-entry.has_sub_navigation .sub_navigation a[href='/admin/layoutpages']")
    end
  end

  context "with a missing legacy controller" do
    let(:attributes) { {url: nil, condition: nil, controller: "bad", action: "index"} }

    it "raises an understandable error" do
      expect { render }.to raise_error(
        "Error in AlchemyCMS module definition: 'pages'. Could not find the matching controller class BadController for the specified controller: 'bad'"
      )
    end
  end
end
