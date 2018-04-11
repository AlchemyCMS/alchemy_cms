# frozen_string_literal: true

require 'spec_helper'

describe "The Routing" do
  routes { Alchemy::Engine.routes }

  describe "root url" do
    it "routes to pages_controller#index" do
      expect({
        get: "/"
      }).to route_to(
        controller: "alchemy/pages",
        action: "index"
      )
    end

    context 'with locale parameter' do
      it 'routes to pages_controller#index' do
        expect({
          get: '/en'
        }).to route_to(
          controller: 'alchemy/pages',
          action: 'index',
          locale: 'en'
        )
      end

      context 'that contains uppercase country code' do
        it 'routes to pages_controller#index' do
          expect({
            get: '/en-UK'
          }).to route_to(
            controller: 'alchemy/pages',
            action: 'index',
            locale: 'en-UK'
          )
        end
      end
    end
  end

  context "for downloads" do
    it "should have a named route" do
      expect({
        get: "/attachment/32/download/Presseveranstaltung.pdf"
      }).to route_to(
        controller: "alchemy/attachments",
        action: "download",
        id: "32",
        name: "Presseveranstaltung",
        format: "pdf"
      )
    end
  end

  describe "nested url" do
    context "one level deep nested" do
      it "should route to pages show" do
        expect({
          get: "/products/my-product"
        }).to route_to(
          controller: "alchemy/pages",
          action: "show",
          urlname: "products/my-product"
        )
      end

      context "and language" do
        it "should route to pages show" do
          expect({
            get: "/de/products/my-product"
          }).to route_to(
            controller: "alchemy/pages",
            action: "show",
            urlname: "products/my-product",
            locale: "de"
          )
        end
      end
    end

    context "two levels deep nested" do
      it "should route to pages show" do
        expect({
          get: "/catalog/products/my-product"
        }).to route_to(
          controller: "alchemy/pages",
          action: "show",
          urlname: "catalog/products/my-product"
        )
      end

      context "and language" do
        it "should route to pages show" do
          expect({
            get: "/de/catalog/products/my-product"
          }).to route_to(
            controller: "alchemy/pages",
            action: "show",
            urlname: "catalog/products/my-product",
            locale: "de"
          )
        end
      end
    end

    context "with a blog date url" do
      it "should route to pages show" do
        expect({
          get: "/2011/12/08/my-post"
        }).to route_to(
          controller: "alchemy/pages",
          action: "show",
          urlname: "2011/12/08/my-post"
        )
      end

      context "and language" do
        it "should route to pages show" do
          expect({
            get: "/de/2011/12/08/my-post"
          }).to route_to(
            controller: "alchemy/pages",
            action: "show",
            urlname: "2011/12/08/my-post",
            locale: "de"
          )
        end
      end
    end
  end

  describe "image format requests" do
    it "should not be handled by alchemy/pages controller" do
      expect({
        get: "/products/my-product.jpg"
      }).not_to be_routable
    end
  end

  describe "rss feed requests" do
    it "should be handled by alchemy/pages controller" do
      expect({
        get: "/news.rss"
      }).to route_to(
        controller: "alchemy/pages",
        action: "show",
        urlname: "news",
        format: "rss"
      )
    end
  end

  describe "unknown formats" do
    it "should be handled by alchemy/pages controller" do
      expect({
        get: "/index.php?id=234"
      }).to route_to(
        controller: "alchemy/pages",
        action: "show",
        urlname: "index",
        format: "php",
        id: "234"
      )

      expect({
        get: "/action.do"
      }).to route_to(
        controller: "alchemy/pages",
        action: "show",
        urlname: "action",
        format: "do"
      )
    end
  end

  describe "Rails info requests" do
    it "should not be handled by alchemy/pages controller" do
      expect({
        get: "/rails/info/routes"
      }).not_to be_routable
    end
  end

  context "for admin interface" do
    context "default" do
      it "should route to admin dashboard" do
        expect({
          get: "/admin/dashboard"
        }).to route_to(
          controller: "alchemy/admin/dashboard",
          action: "index"
        )
      end

      it "should route to page preview" do
        expect({
          get: "/admin/pages/3/preview"
        }).to route_to(
          controller: "alchemy/admin/pages",
          action: "preview",
          id: "3"
        )
      end
    end

    context "customized" do
      before(:all) do
        Alchemy.admin_path = "backend"
        Alchemy.admin_constraints = {subdomain: "hidden"}
        Rails.application.reload_routes!
      end

      it "should route to admin dashboard" do
        expect({
          get: "http://hidden.example.org/backend/dashboard"
        }).to route_to(
          controller: "alchemy/admin/dashboard",
          action: "index",
          subdomain: "hidden"
        )
      end

      it "should route to page preview" do
        expect({
          get: "http://hidden.example.org/backend/pages/3/preview"
        }).to route_to(
          controller: "alchemy/admin/pages",
          action: "preview",
          id: "3",
          subdomain: "hidden"
        )
      end

      after(:all) do
        Alchemy.admin_path = "admin"
        Alchemy.admin_constraints = {}
        Rails.application.reload_routes!
      end
    end
  end
end
