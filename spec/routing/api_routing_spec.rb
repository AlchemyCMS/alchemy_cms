# frozen_string_literal: true

require "rails_helper"

describe "The API routes" do
  routes { Alchemy::Engine.routes }

  describe "for pages" do
    it "has route to show all pages." do
      expect({ get: "/api/pages.json" }).to route_to(
        controller: "alchemy/api/pages",
        action: "index",
        format: "json",
      )
    end

    context "with missing format" do
      it "defaults to json." do
        expect({ get: "/api/pages" }).to route_to(
          controller: "alchemy/api/pages",
          action: "index",
          format: "json",
        )
      end
    end

    it "has route to show a page by urlname." do
      expect({ get: "/api/pages/a-page.json" }).to route_to(
        controller: "alchemy/api/pages",
        action: "show",
        urlname: "a-page",
        format: "json",
      )
    end

    it "has route to show a page by nested urlname." do
      expect({ get: "/api/pages/nested/a-page" }).to route_to(
        controller: "alchemy/api/pages",
        action: "show",
        urlname: "nested/a-page",
        format: "json",
      )
    end

    context "with admin namespace" do
      it "routes to api pages controller." do
        expect({ get: "/api/admin/pages/8" }).to route_to(
          controller: "alchemy/api/pages",
          action: "show",
          id: "8",
          format: "json",
        )
      end
    end
  end

  describe "for elements" do
    it "has route to show all elements." do
      expect({ get: "/api/elements.json" }).to route_to(
        controller: "alchemy/api/elements",
        action: "index",
        format: "json",
      )
    end

    context "with missing format" do
      it "defaults to json." do
        expect({ get: "/api/elements" }).to route_to(
          controller: "alchemy/api/elements",
          action: "index",
          format: "json",
        )
      end
    end

    it "has route to show all elements for page id." do
      expect({ get: "/api/pages/1/elements.json" }).to route_to(
        controller: "alchemy/api/elements",
        action: "index",
        page_id: "1",
        format: "json",
      )
    end

    it "has route to show all elements for page id and name." do
      expect({ get: "/api/pages/1/elements/article.json" }).to route_to(
        controller: "alchemy/api/elements",
        action: "index",
        page_id: "1",
        named: "article",
        format: "json",
      )
    end

    it "has route to show an element." do
      expect({ get: "/api/elements/1.json" }).to route_to(
        controller: "alchemy/api/elements",
        action: "show",
        id: "1",
        format: "json",
      )
    end
  end
end
