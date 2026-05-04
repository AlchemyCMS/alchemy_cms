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
    #   Products (standard)                                -> /products
    #   +-- Product Detail (page_with_wildcard_url)        -> /products/:slug
    #       +-- Comments (standard)                        -> /products/:slug/comments

    let!(:products_page) { create_page(name: "Products") }
    let!(:product_detail_page) { create_page(name: "Product Detail", layout: "page_with_wildcard_url", parent: products_page) }
    let!(:comments_page) { create_page(name: "Comments", parent: product_detail_page) }

    it "finds a wildcard page and extracts params" do
      result = described_class.new("products/123").call
      expect(result.page).to eq(product_detail_page)
      expect(result.extracted_params[:slug]).to eq("123")
    end

    it "finds a page by exact urlname" do
      result = described_class.new("products").call
      expect(result.page).to eq(products_page)
    end

    it "finds a nested page by its full urlname" do
      result = described_class.new(comments_page.urlname).call
      expect(result.page).to eq(comments_page)
    end

    it "returns nil for a blank path" do
      expect(described_class.new("").call).to be_nil
    end

    it "returns nil for a path with no matching prefix" do
      expect(described_class.new("other/123").call).to be_nil
    end

    context "hierarchical patterns (grandchild under pattern page)" do
      it "matches /products/42/comments through the pattern parent" do
        result = described_class.new("products/42/comments").call
        expect(result.page).to eq(comments_page)
        expect(result.extracted_params[:slug]).to eq("42")
      end
    end

    it "prefers exact urlname match over wildcard match" do
      result = described_class.new("products").call
      expect(result.page).to eq(products_page)
      expect(result.extracted_params).to be_empty
    end

    context "with multiple wildcard pages at the same depth" do
      let!(:services_page) { create_page(name: "Services") }
      let!(:service_detail_page) { create_page(name: "Service Detail", layout: "page_with_wildcard_url", parent: services_page) }

      it "matches each wildcard page by its static prefix" do
        product_result = described_class.new("products/abc").call
        expect(product_result.page).to eq(product_detail_page)

        service_result = described_class.new("services/xyz").call
        expect(service_result.page).to eq(service_detail_page)
      end
    end

    context "depth filtering" do
      it "does not match a wildcard page at a different depth" do
        expect(described_class.new("products/123/extra/segment").call).to be_nil
      end

      it "does not match a single-segment URL against a two-segment wildcard" do
        expect(described_class.new("anything").call).to be_nil
      end
    end

    context "with regex metacharacters in the URL" do
      it "escapes static segments so metacharacters cannot alter matching" do
        expect(described_class.new("products/.123").call).to be_nil
      end
    end

    context "with nested wildcard pages" do
      before do
        PageDefinition.add(name: "nested_wildcard", wildcard_url: :variant_id, elements: [])
      end

      after do
        PageDefinition.reset!
      end

      let!(:variant_page) do
        create_page(name: "Test", layout: "nested_wildcard", parent: product_detail_page)
      end

      it "extracts two parameters from a single urlname" do
        result = described_class.new("products/42/test").call
        expect(result.page).to eq(variant_page)
        expect(result.extracted_params[:slug]).to eq("42")
        expect(result.extracted_params[:variant_id]).to eq("test")
      end
    end

    context "with multiple language trees" do
      let(:german_language) { create(:alchemy_language, :german) }
      let!(:german_root) do
        create(:alchemy_page, :language_root, language: german_language)
      end
      let!(:german_products_page) do
        create(:alchemy_page, :public,
          name: "Produkte",
          page_layout: "standard",
          parent: german_root,
          language: german_language)
      end
      let!(:german_detail_page) do
        create(:alchemy_page, :public,
          name: "Detail",
          page_layout: "page_with_wildcard_url",
          parent: german_products_page,
          language: german_language)
      end

      it "returns the wildcard page from the current language" do
        result = described_class.new("products/123").call
        expect(result.page).to eq(product_detail_page)
        expect(result.page.language).to eq(language)
      end

      it "returns the German wildcard page when Current.language is German" do
        Current.language = german_language
        result = described_class.new("produkte/123").call
        expect(result.page).to eq(german_detail_page)
        expect(result.page.language).to eq(german_language)
      end

      it "returns nil for a urlname that exists only in another language" do
        Current.language = german_language
        expect(described_class.new("products/123").call).to be_nil
      end
    end
  end
end
