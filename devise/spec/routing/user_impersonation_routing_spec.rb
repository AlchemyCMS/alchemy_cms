require "rails_helper"

RSpec.describe Alchemy::Admin::UserImpersonationsController, type: :routing do
  routes { Alchemy::Engine.routes }

  it "routes starting impersonation via POST" do
    expect(post: "/admin/users/42/impersonation").to route_to(
      controller: "alchemy/admin/user_impersonations",
      action: "create",
      user_id: "42"
    )
  end

  it "does not route starting impersonation via GET" do
    expect(get: "/admin/users/42/impersonation").not_to route_to(
      controller: "alchemy/admin/user_impersonations",
      action: "create",
      user_id: "42"
    )
  end

  it "routes stopping impersonation via DELETE" do
    expect(delete: "/admin/impersonation").to route_to(
      controller: "alchemy/admin/user_impersonations",
      action: "destroy"
    )
  end

  it "does not route stopping impersonation via GET" do
    expect(get: "/admin/impersonation").not_to route_to(
      controller: "alchemy/admin/user_impersonations",
      action: "destroy"
    )
  end
end
