require 'spec_helper'

describe "The Routing" do
  routes { Alchemy::Engine.routes }

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

  describe "for displaying pictures" do
    it "should route to show action" do
      expect({
        get: "/pictures/3/show/900x300/kitten.jpg"
      }).to route_to(
        controller: "alchemy/pictures",
        action: "show",
        id: "3",
        size: "900x300",
        name: "kitten",
        format: "jpg"
      )
    end

    it "should route to cropped show action" do
      expect({
        get: "/pictures/3/show/900x300/crop/kitten.jpg"
      }).to route_to(
        controller: "alchemy/pictures",
        action: "show",
        id: "3",
        size: "900x300",
        crop: "crop",
        name: "kitten",
        format: "jpg"
      )
    end

    it "should route to cropped mask show action" do
      expect(get(
        "/pictures/3/show/300x300/crop/200x50/100x100/kitten.jpg"
      )).to route_to(
        controller: "alchemy/pictures",
        action: "show",
        id: "3",
        size: "300x300",
        crop: "crop",
        crop_from: "200x50",
        crop_size: "100x100",
        name: "kitten",
        format: "jpg"
      )
    end

    it "should route to thumbnail action" do
      expect(get(
        "/pictures/3/thumbnails/small/kitten.jpg"
      )).to route_to(
        controller: "alchemy/pictures",
        action: "thumbnail",
        id: "3",
        size: "small",
        name: "kitten",
        format: "jpg"
      )
    end

    it "should route to cropped thumbnail action" do
      expect(get(
        "/pictures/3/thumbnails/small/crop/kitten.jpg"
      )).to route_to(
        controller: "alchemy/pictures",
        action: "thumbnail",
        id: "3",
        crop: "crop",
        size: "small",
        name: "kitten",
        format: "jpg"
      )
    end

    it "should route to cropped and masked thumbnail" do
      expect(get(
        "/pictures/3/thumbnails/small/0x0/200x200/kitten.jpg"
      )).to route_to(
        controller: "alchemy/pictures",
        action: "thumbnail",
        id: "3",
        crop_from: "0x0",
        crop_size: "200x200",
        size: "small",
        name: "kitten",
        format: "jpg"
      )
    end

    it "should route to zoomed picture" do
      expect(get(
        "/pictures/3/zoom/kitten.jpg"
      )).to route_to(
        controller: "alchemy/pictures",
        action: "zoom",
        id: "3",
        name: "kitten",
        format: "jpg"
      )
    end
  end

  describe "image format requests" do
    it "should not be handled by alchemy/pages controller" do
      expect({
        get: "/products/my-product.jpg"
      }).not_to be_routable
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
end
