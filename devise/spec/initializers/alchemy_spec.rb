require "rails_helper"

RSpec.describe "Alchemy initializer" do
  it "lists the users entry between languages and sites in the menu" do
    expect(Alchemy::Admin::MainNavigation::Menu.new.items.map(&:name).first(6)).to eq(%w[dashboard pages menus languages users sites])
  end

  it "links the users entry to the users admin" do
    users = Alchemy.config.menu.find { |item| item.name == "users" }
    view_context = double("view context", alchemy: Alchemy::Engine.routes.url_helpers)
    expect(users.path(view_context)).to eq("/admin/users")
  end
end
