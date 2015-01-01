require 'spec_helper'

describe "User Routing" do
  routes { Alchemy::Engine.routes }

  it "routes to signup" do
    expect({
      get: "/admin/signup"
    }).to route_to(
      controller: "alchemy/users",
      action: "new"
    )
  end

  it "routes to create user" do
    expect({
      post: "/users"
    }).to route_to(
      controller: "alchemy/users",
      action: "create"
    )
  end
end
