require 'spec_helper'

describe "The Routing" do

  routes { Alchemy::Engine.routes }

  context "for downloads" do

    it "should have a named route" do
      {
        :get => "/attachment/32/download/Presseveranstaltung.pdf"
      }.should route_to(
        :controller => "alchemy/attachments",
        :action => "download",
        :id => "32",
        :name => "Presseveranstaltung",
        :format => "pdf"
      )
    end

  end

  describe "nested url" do

    context "one level deep nested" do

      it "should route to pages show" do
        {
          :get => "/products/my-product"
        }.should route_to(
          :controller => "alchemy/pages",
          :action => "show",
          :urlname => "products/my-product"
        )
      end

      context "and language" do

        it "should route to pages show" do
          {
            :get => "/de/products/my-product"
          }.should route_to(
            :controller => "alchemy/pages",
            :action => "show",
            :urlname => "products/my-product",
            :lang => "de"
          )
        end

      end

    end

    context "two levels deep nested" do

      it "should route to pages show" do
        {
          :get => "/catalog/products/my-product"
        }.should route_to(
          :controller => "alchemy/pages",
          :action => "show",
          :urlname => "catalog/products/my-product"
        )
      end

      context "and language" do

        it "should route to pages show" do
          {
            :get => "/de/catalog/products/my-product"
          }.should route_to(
            :controller => "alchemy/pages",
            :action => "show",
            :urlname => "catalog/products/my-product",
            :lang => "de"
          )
        end

      end

    end

    context "with a blog date url" do

      it "should route to pages show" do
        {
          :get => "/2011/12/08/my-post"
        }.should route_to(
          :controller => "alchemy/pages",
          :action => "show",
          :urlname => "2011/12/08/my-post"
        )
      end

      context "and language" do

        it "should route to pages show" do
          {
            :get => "/de/2011/12/08/my-post"
          }.should route_to(
            :controller => "alchemy/pages",
            :action => "show",
            :urlname => "2011/12/08/my-post",
            :lang => "de"
          )
        end

      end

    end

  end

  describe "for displaying pictures" do

    it "should route to show action" do
      {
        :get => "/pictures/3/show/900x300/kitten.jpg"
      }.should route_to(
        :controller => "alchemy/pictures",
        :action => "show",
        :id => "3",
        :size => "900x300",
        :name => "kitten",
        :format => "jpg"
      )
    end

    it "should route to cropped show action" do
      {
        :get => "/pictures/3/show/900x300/crop/kitten.jpg"
      }.should route_to(
        :controller => "alchemy/pictures",
        :action => "show",
        :id => "3",
        :size => "900x300",
        :crop => "crop",
        :name => "kitten",
        :format => "jpg"
      )
    end

    it "should route to cropped mask show action" do
      get(
        "/pictures/3/show/300x300/crop/200x50/100x100/kitten.jpg"
      ).should route_to(
        :controller => "alchemy/pictures",
        :action => "show",
        :id => "3",
        :size => "300x300",
        :crop => "crop",
        :crop_from => "200x50",
        :crop_size => "100x100",
        :name => "kitten",
        :format => "jpg"
      )
    end

    it "should route to thumbnail action" do
      get(
        "/pictures/3/thumbnails/small/kitten.jpg"
      ).should route_to(
        :controller => "alchemy/pictures",
        :action => "thumbnail",
        :id => "3",
        :size => "small",
        :name => "kitten",
        :format => "jpg"
      )
    end

    it "should route to cropped thumbnail action" do
      get(
        "/pictures/3/thumbnails/small/crop/kitten.jpg"
      ).should route_to(
        :controller => "alchemy/pictures",
        :action => "thumbnail",
        :id => "3",
        :crop => "crop",
        :size => "small",
        :name => "kitten",
        :format => "jpg"
      )
    end

    it "should route to cropped and masked thumbnail" do
      get(
        "/pictures/3/thumbnails/small/0x0/200x200/kitten.jpg"
      ).should route_to(
        :controller => "alchemy/pictures",
        :action => "thumbnail",
        :id => "3",
        :crop_from => "0x0",
        :crop_size => "200x200",
        :size => "small",
        :name => "kitten",
        :format => "jpg"
      )
    end

    it "should route to zoomed picture" do
      get(
        "/pictures/3/zoom/kitten.jpg"
      ).should route_to(
        :controller => "alchemy/pictures",
        :action => "zoom",
        :id => "3",
        :name => "kitten",
        :format => "jpg"
      )
    end

  end

end
