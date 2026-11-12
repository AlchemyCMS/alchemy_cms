# frozen_string_literal: true

require "rails_helper"

RSpec.describe Alchemy::Liquid::Tags::Menu, type: :helper do
  it "renders the menu with render_menu" do
    expect(helper).to receive(:render_menu).with("main_menu", {}).and_return("<nav></nav>".html_safe)
    expect(render_liquid('{% menu "main_menu" %}')).to eq("<nav></nav>")
  end

  it "passes options to render_menu" do
    expect(helper).to receive(:render_menu).with("footer_navigation", {class: "footer"}).and_return("")
    render_liquid('{% menu "footer_navigation", class: "footer" %}')
  end

  it "renders the menu partials" do
    page = create(:alchemy_page, :public)
    root = create(:alchemy_node, menu_type: "main_menu", name: "Main", language: page.language)
    create(:alchemy_node, menu_type: "main_menu", name: "Child", parent: root, page: page, language: page.language)
    Alchemy::Current.language = page.language

    expect(render_liquid('{% menu "main_menu" %}')).to have_link("Child", href: page.url_path)
  end

  it "raises a syntax error without menu type" do
    expect { render_liquid("{% menu %}") }.to raise_error(ActionView::Template::Error, /needs a menu type/)
  end
end
