# frozen_string_literal: true

require "rails_helper"

describe "alchemy/admin/partials/_routes.html.erb" do
  subject(:routes) do
    render
    JSON.parse(Capybara.string(rendered).find("script#alchemy_routes", visible: false).text(:all))
  end

  it "renders collection routes" do
    expect(routes["collection"]).to include("api_pages_path" => "/api/pages")
  end

  it "renders member routes with 1 as the record id" do
    expect(routes["member"]).to include("fold_admin_page_path" => "/admin/pages/1/fold")
    expect(routes["member"]["node"]).to include("move_api_path" => "/api/nodes/1/move")
  end
end
