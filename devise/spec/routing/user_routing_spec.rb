require 'spec_helper'

describe "User Routing" do
  routes { Alchemy::Engine.routes }

  it "routes to signup" do
    expect({
      get: "/admin/signup"
    }).to route_to(
      controller: "alchemy/admin/users",
      action: "signup"
    )
  end
end
