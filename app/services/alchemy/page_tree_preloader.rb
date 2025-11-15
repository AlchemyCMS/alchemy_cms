# frozen_string_literal: true

module Alchemy
  # Preloads page trees with all associations and children
  #
  # This service efficiently loads page trees to avoid N+1 queries.
  # It handles folded pages and preloads all necessary associations.
  #
  # @example Preload subtree from a specific page
  #   preloader = Alchemy::PageTreePreloader.new(page: page, user: current_user)
  #   page_with_descendants = preloader.call
  #
  class PageTreePreloader
    # @param page [Page] Starting page for loading descendants
    # @param user [User, nil] User for folding support
    def initialize(page:, user: nil)
      @page = page
      @user = user
    end

    # Preloads and returns the page tree
    #
    # @return [Array<Page>] Pages with preloaded children, or array with single page when using from:
    def call
      pages = page.self_and_descendants
      folded_page_ids = load_folded_page_ids
      if folded_page_ids.any?
        pages = pages.where(
          "parent_id IS NULL OR parent_id NOT IN (?)",
          folded_page_ids
        )
      end
      pages = pages.preload(*preload_associations)
      pages = pages.map { PageTreePage.new(_1) }

      preload_children_associations(pages, folded_page_ids:)

      # Return the starting page, which now has preloaded descendants
      # We need to return the actual instance from the pages array, not the @page instance
      # because the children associations were set on the pages array instances
      pages.find { |p| p.id == page.id }
    end

    private

    attr_reader :page, :user

    # Load folded page IDs for the user
    def load_folded_page_ids
      if user && Alchemy.user_class < ActiveRecord::Base
        FoldedPage.folded_for_user(user).pluck(:page_id).to_set
      else
        Set.new
      end
    end

    # Preload children associations for a collection of pages
    # This manually populates the children association to prevent N+1 queries
    #
    # @param pages [Array<Page>] The pages to preload children for
    # @param folded_page_ids [Set] Optional set of page IDs that should have empty children
    # @return [void]
    def preload_children_associations(pages, folded_page_ids: Set.new)
      # Group pages by parent_id for efficient lookup
      pages_by_parent = pages.group_by(&:parent_id)

      # Manually populate the children association for each page
      pages.each do |page|
        children_records = pages_by_parent[page.id] || []

        # If page is folded, set children to empty array
        collection = if folded_page_ids.include?(page.id)
          page.folded = true
          []
        else
          page.folded = false
          children_records.sort_by(&:lft)
        end
        page.association(:children).target = collection
        page.association(:children).loaded!
      end
    end

    # Associations to preload for sitemap rendering
    def preload_associations
      [:public_version, {language: {site: :languages}}]
    end
  end

  class PageTreePage < SimpleDelegator
    attr_accessor :folded
    alias_method :folded?, :folded
  end
end
