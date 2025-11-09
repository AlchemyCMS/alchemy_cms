# frozen_string_literal: true

module Alchemy
  # Preloads page trees with all associations and children
  #
  # This service efficiently loads page trees to avoid N+1 queries.
  # It handles folded pages and preloads all necessary associations.
  #
  # @example Preload all pages for a language
  #   preloader = Alchemy::PageTreePreloader.new(language: language, user: current_user)
  #   root_pages = preloader.call
  #
  # @example Preload subtree from a specific page
  #   preloader = Alchemy::PageTreePreloader.new(from: page, user: current_user)
  #   page_with_descendants = preloader.call
  #
  class PageTreePreloader
    # @param from [Page, nil] Starting page for loading descendants
    # @param language [Language, nil] Language to load pages for (loads all language's contentpages)
    # @param user [User, nil] User for folding support
    def initialize(from: nil, language: nil, user: nil)
      @from = from
      @language = language
      @user = user
    end

    # Preloads and returns the page tree
    #
    # @return [Array<Page>] Root pages with preloaded children, or array with single page when using from:
    def call
      pages = load_pages
      return pages if pages.empty?

      folded_page_ids = load_folded_page_ids
      preload_children_associations(pages, folded_page_ids: folded_page_ids)

      return_result(pages)
    end

    private

    attr_reader :from, :language, :user

    # Load the initial page collection
    def load_pages
      if from
        # Load subtree from specific page
        from.self_and_descendants.preload(*preload_associations, :folded_pages).to_a
      elsif language
        # Load all contentpages for language
        Page.with_language(language.id).contentpages.preload(*preload_associations, :folded_pages).to_a
      else
        Rails.logger.warn("Neither a start page not language given! Skipping preloading pages.")
        []
      end
    end

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
        page.association(:children).target = if folded_page_ids.include?(page.id)
          []
        else
          children_records.sort_by(&:lft)
        end
        page.association(:children).loaded!
      end
    end

    # Return appropriate result based on input
    def return_result(pages)
      if from
        # Return the starting page in an array (which now has preloaded descendants)
        # We need to return the actual instance from the pages array, not the @from instance
        # because the children associations were set on the pages array instances
        starting_page = pages.find { |p| p.id == from.id } || from
        [starting_page]
      else
        # Return only root pages - their children are now preloaded
        pages.group_by(&:parent_id)[nil] || []
      end
    end

    # Associations to preload for sitemap rendering
    def preload_associations
      Page.sitemap_preload_associations
    end
  end
end
