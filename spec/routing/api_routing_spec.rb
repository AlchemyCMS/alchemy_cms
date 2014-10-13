require 'spec_helper'

describe 'The API routes' do
  routes { Alchemy::Engine.routes }

  describe "for pages" do
    it "has route to api/pages controller." do
      expect({get: "/api/pages/a-page.json"}).to route_to(
        controller: "alchemy/api/pages",
        action: "show",
        urlname: "a-page",
        format: "json"
      )
    end

    context 'with missing format' do
      it "defaults to json." do
        expect({get: "/api/pages/a-page"}).to route_to(
          controller: "alchemy/api/pages",
          action: "show",
          urlname: "a-page",
          format: "json"
        )
      end
    end

    context 'with nested urlname' do
      it "defaults to json." do
        expect({get: "/api/pages/nested/a-page"}).to route_to(
          controller: "alchemy/api/pages",
          action: "show",
          urlname: "nested/a-page",
          format: "json"
        )
      end
    end
  end
end