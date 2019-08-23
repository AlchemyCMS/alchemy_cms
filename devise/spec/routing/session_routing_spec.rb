require 'rails_helper'

describe "Session Routing" do
  routes { Alchemy::Engine.routes }

  it "routes to login" do
    expect({
      get: "/admin/login"
    }).to route_to(
      controller: "alchemy/user_sessions",
      action: "new"
    )
  end

  it "routes to create session" do
    expect({
      post: "/admin/login"
    }).to route_to(
      controller: "alchemy/user_sessions",
      action: "create"
    )
  end

  it "routes to logout" do
    expect({
      delete: "/admin/logout"
    }).to route_to(
      controller: "alchemy/user_sessions",
      action: "destroy"
    )
  end
end
