# frozen_string_literal: true

require "rails_helper"

module Alchemy
  RSpec.describe PageFinder do
    let(:language) { create(:alchemy_language) }
    let!(:language_root) do
      create(:alchemy_page, :language_root, language: language)
    end

    before do
      PageDefinition.reset!
      Current.language = language
    end

    def create_page(name:, layout: "standard", parent: language_root)
      create(
        :alchemy_page, :public,
        name: name,
        page_layout: layout,
        parent: parent,
        language: language
      )
    end

    # Page tree used by most tests:
    #
    #   Products (standard)                      -> /products
    #   +-- Product Details (product_detail)     -> /products/:id        (integer constraint)
    #   |   +-- Comments (standard)              -> /products/:id/comments
    #   +-- Product By Slug (product_by_slug)    -> /products/:slug      (no constraint)
    #
    #   Blog (standard)                          -> /blog
    #   +-- Blog Post (blog_post)                -> /blog/:year/:slug   (integer + string)
    #
    #   Users (standard)                         -> /users
    #   +-- User Profile (user_profile)          -> /users/:uuid/profile (uuid constraint)

    let!(:products_page) { create_page(name: "Products") }
    let!(:product_detail_page) { create_page(name: "Product Details", layout: "product_detail", parent: products_page) }
    let!(:comments_page) { create_page(name: "Comments", parent: product_detail_page) }
    let!(:product_by_slug_page) { create_page(name: "Product By Slug", layout: "product_by_slug", parent: products_page) }

    let!(:blog_page) { create_page(name: "Blog") }
    let!(:blog_post_page) { create_page(name: "Blog Post", layout: "blog_post", parent: blog_page) }

    let!(:users_page) { create_page(name: "Users") }
    let!(:user_profile_page) { create_page(name: "User Profile", layout: "user_profile", parent: users_page) }

    let(:params) { ActionController::Parameters.new }

    it "defaults to Current.language.root_page" do
      page = described_class.new(params: params).call("products/123")
      expect(page).to eq(product_detail_page)
      expect(params[:id]).to eq("123")
    end

    it "finds a page by exact urlname" do
      page = described_class.new(params: params).call("products")
      expect(page).to eq(products_page)
    end

    it "finds a nested page by its full urlname" do
      page = described_class.new(params: params).call(comments_page.urlname)
      expect(page).to eq(comments_page)
    end

    it "returns nil for a blank path" do
      expect(described_class.new(params: params).call("")).to be_nil
    end

    it "returns nil for a path with no matching prefix" do
      expect(described_class.new(params: params).call("other/123")).to be_nil
    end

    context "single-segment pattern with integer constraint" do
      it "matches /products/123" do
        page = described_class.new(params: params).call("products/123")
        expect(page).to eq(product_detail_page)
        expect(params[:id]).to eq("123")
      end

      it "rejects non-integer and falls through to unconstrained sibling" do
        page = described_class.new(params: params).call("products/some-slug")
        expect(page).to eq(product_by_slug_page)
        expect(params[:slug]).to eq("some-slug")
        # ensures no stale params leak from the failed product_detail match
        expect(params).not_to have_key(:id)
      end
    end

    context "multi-segment pattern" do
      it "matches /blog/2024/my-post and extracts both params" do
        page = described_class.new(params: params).call("blog/2024/my-post")
        expect(page).to eq(blog_post_page)
        expect(params[:year]).to eq("2024")
        expect(params[:slug]).to eq("my-post")
      end

      it "does not match with wrong segment count" do
        expect(described_class.new(params: params).call("blog/2024")).to be_nil
      end
    end

    context "pattern with static segments" do
      let(:uuid) { "550e8400-e29b-41d4-a716-446655440000" }

      it "matches /users/:uuid/profile" do
        page = described_class.new(params: params).call("users/#{uuid}/profile")
        expect(page).to eq(user_profile_page)
        expect(params[:uuid]).to eq(uuid)
      end

      it "does not match without the trailing static segment" do
        expect(described_class.new(params: params).call("users/#{uuid}")).to be_nil
      end
    end

    context "hierarchical patterns (grandchild under pattern page)" do
      it "matches /products/42/comments through the pattern parent" do
        page = described_class.new(params: params).call("products/42/comments")
        expect(page).to eq(comments_page)
        expect(params[:id]).to eq("42")
      end
    end

    context "nested wildcard patterns" do
      let!(:category_page) { create_page(name: "Category") }
      let!(:category_by_slug) { create_page(name: "Category By Slug", layout: "product_by_slug", parent: category_page) }
      let!(:category_detail) { create_page(name: "Category Detail", layout: "product_detail", parent: category_by_slug) }

      it "matches /category/electronics/42 and extracts both slug and id" do
        page = described_class.new(params: params).call("category/electronics/42")
        expect(page).to eq(category_detail)
        expect(params[:slug]).to eq("electronics")
        expect(params[:id]).to eq("42")
      end
    end

    context "with competing sibling patterns of different segment counts" do
      let!(:shared_page) { create_page(name: "Shared") }
      let!(:multi_segment_page) { create_page(name: "Multi Segment", layout: "blog_post", parent: shared_page) }
      let!(:single_segment_page) { create_page(name: "Single Segment", layout: "product_by_slug", parent: shared_page) }
      let!(:child_of_single) { create_page(name: "My Post", parent: single_segment_page) }

      it "matches the first pattern sibling even when the other could also match via its child" do
        page = described_class.new(params: params).call("shared/2024/my-post")
        expect(page).to eq(multi_segment_page)
        expect(params[:year]).to eq("2024")
        expect(params[:slug]).to eq("my-post")
      end
    end

    context "with a static wildcard_url pattern (no dynamic segments)" do
      let!(:static_parent) { create_page(name: "Static Parent") }
      let!(:static_page) { create_page(name: "Static Page", layout: "static_wildcard", parent: static_parent) }

      it "matches /static-parent/foo/bar" do
        page = described_class.new(params: params).call("static-parent/foo/bar")
        expect(page).to eq(static_page)
        expect(params.keys).to be_empty
      end
    end

    context "with a regex constraint" do
      let!(:warehouse_page) { create_page(name: "Warehouse") }
      let!(:sku_page) { create_page(name: "SKU Lookup", layout: "product_by_sku", parent: warehouse_page) }

      it "matches when the value satisfies the regex" do
        page = described_class.new(params: params).call("warehouse/AB-1234")
        expect(page).to eq(sku_page)
        expect(params[:sku]).to eq("AB-1234")
      end

      it "does not match when the value violates the regex" do
        expect(described_class.new(params: params).call("warehouse/invalid")).to be_nil
      end
    end
  end

  RSpec.describe PageFinder, "when no content pages exist" do
    let(:language) { create(:alchemy_language) }
    let!(:language_root) do
      create(:alchemy_page, :language_root, language: language)
    end

    before do
      PageDefinition.reset!
      Current.language = language
    end

    it "returns nil" do
      expect(described_class.new.call("anything")).to be_nil
    end
  end
end
