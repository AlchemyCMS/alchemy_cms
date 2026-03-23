# frozen_string_literal: true

require "rails_helper"

module Alchemy
  RSpec.describe UrlPatternMatcher do
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

    it "returns nil for a blank path" do
      expect(described_class.new("").page).to be_nil
    end

    it "returns nil for a path with no matching prefix" do
      expect(described_class.new("other/123").page).to be_nil
    end

    context "single-segment pattern with integer constraint" do
      it "matches /products/123" do
        matcher = described_class.new("products/123")
        expect(matcher.page).to eq(product_detail_page)
        expect(matcher.params[:id]).to eq("123")
      end

      it "rejects non-integer and falls through to unconstrained sibling" do
        matcher = described_class.new("products/some-slug")
        expect(matcher.page).to eq(product_by_slug_page)
        expect(matcher.params[:slug]).to eq("some-slug")
      end
    end

    context "multi-segment pattern" do
      it "matches /blog/2024/my-post and extracts both params" do
        matcher = described_class.new("blog/2024/my-post")
        expect(matcher.page).to eq(blog_post_page)
        expect(matcher.params[:year]).to eq("2024")
        expect(matcher.params[:slug]).to eq("my-post")
      end

      it "does not match with wrong segment count" do
        expect(described_class.new("blog/2024").page).to be_nil
      end
    end

    context "pattern with static segments" do
      let(:uuid) { "550e8400-e29b-41d4-a716-446655440000" }

      it "matches /users/:uuid/profile" do
        matcher = described_class.new("users/#{uuid}/profile")
        expect(matcher.page).to eq(user_profile_page)
        expect(matcher.params[:uuid]).to eq(uuid)
      end

      it "does not match without the trailing static segment" do
        expect(described_class.new("users/#{uuid}").page).to be_nil
      end
    end

    context "hierarchical patterns (grandchild under pattern page)" do
      it "matches /products/42/comments through the pattern parent" do
        matcher = described_class.new("products/42/comments")
        expect(matcher.page).to eq(comments_page)
        expect(matcher.params[:id]).to eq("42")
      end
    end

    context "with two unconstrained sibling pages of the same layout" do
      let!(:second_product_by_slug_page) { create_page(name: "Second Product By Slug", layout: "product_by_slug", parent: products_page) }

      it "matches the first sibling returned by the database" do
        matcher = described_class.new("products/widget")
        expect(matcher.page).to eq(product_by_slug_page)
      end
    end

    context "with competing sibling patterns of different segment counts" do
      let!(:shared_page) { create_page(name: "Shared") }
      let!(:multi_segment_page) { create_page(name: "Multi Segment", layout: "blog_post", parent: shared_page) }
      let!(:single_segment_page) { create_page(name: "Single Segment", layout: "product_by_slug", parent: shared_page) }
      let!(:child_of_single) { create_page(name: "My Post", parent: single_segment_page) }

      it "matches the first pattern sibling even when the other could also match via its child" do
        matcher = described_class.new("shared/2024/my-post")
        expect(matcher.page).to eq(multi_segment_page)
        expect(matcher.params[:year]).to eq("2024")
        expect(matcher.params[:slug]).to eq("my-post")
      end
    end

    context "with a regex constraint" do
      let!(:warehouse_page) { create_page(name: "Warehouse") }
      let!(:sku_page) { create_page(name: "SKU Lookup", layout: "product_by_sku", parent: warehouse_page) }

      it "matches when the value satisfies the regex" do
        matcher = described_class.new("warehouse/AB-1234")
        expect(matcher.page).to eq(sku_page)
        expect(matcher.params[:sku]).to eq("AB-1234")
      end

      it "does not match when the value violates the regex" do
        matcher = described_class.new("warehouse/invalid")
        expect(matcher.page).to be_nil
      end
    end
  end
end
