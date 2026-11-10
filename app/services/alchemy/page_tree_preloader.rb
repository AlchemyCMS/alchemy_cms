# frozen_string_literal: true

module Alchemy
  # Preloads page trees with all associations and children
  #
  # This service efficiently loads page trees to avoid N+1 queries.
  # It handles folded pages and preloads all necessary associations.
  #
  # @example Preload subtree from a specific page
  #   preloader = Alchemy::PageTreePreloader.new(page: page, ability: current_ability, user: current_user)
  #   page_with_descendants = preloader.call
  #
  class PageTreePreloader
    # @param page [Page] Starting page for loading descendants
    # @param ability [CanCan::Ability] Ability used to scope descendants to readable pages
    # @param user [User, nil] User for folding support
    def initialize(page:, ability:, user: nil)
      @page = page
      @ability = ability
      @user = user
    end

    # Preloads and returns the page tree
    #
    # @return [Array<Page>] Pages with preloaded children, or array with single page when using from:
    def call
      pages = page.self_and_descendants.accessible_by(ability, :read)
      fold_states = load_fold_states
      if fold_states
        folded_page_ids = fold_states.select { |_id, folded| folded }.keys
        unfolded_page_ids = fold_states.reject { |_id, folded| folded }.keys
        table = Page.arel_table
        pages = pages.where(
          table[:id].eq(page.id)
            .or(table[:depth].lteq(1).and(table[:parent_id].not_in(folded_page_ids)))
            .or(table[:parent_id].in(unfolded_page_ids))
        )
      end
      pages = pages.preload(*preload_associations)
      pages = pages.map { PageTreePage.new(_1) }

      preload_children_associations(pages, fold_states:)

      # Return the starting page, which now has preloaded descendants
      # We need to return the actual instance from the pages array, not the @page instance
      # because the children associations were set on the pages array instances
      pages.find { |p| p.id == page.id }
    end

    private

    attr_reader :page, :user, :ability

    # Load the user's persisted fold states as page_id => folded,
    # or nil if folding is not supported for the user
    def load_fold_states
      if user && Alchemy.config.user_class < ActiveRecord::Base
        FoldedPage.where(user: user).pluck(:page_id, :folded).to_h
      end
    end

    # Preload children associations for a collection of pages
    # This manually populates the children association to prevent N+1 queries
    #
    # @param pages [Array<Page>] The pages to preload children for
    # @param fold_states [Hash, nil] Persisted fold states by page id. Pages without a
    #   state are folded below the first level. Without fold states nothing is folded.
    # @return [void]
    def preload_children_associations(pages, fold_states: nil)
      # Group pages by parent_id for efficient lookup
      pages_by_parent = pages.group_by(&:parent_id)

      # Manually populate the children association for each page
      pages.each do |page|
        children_records = pages_by_parent[page.id] || []

        # If page is folded, set children to empty array
        folded = fold_states&.fetch(page.id) { page.depth.to_i >= 1 && !page.leaf? }
        collection = if folded
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
      associations = [
        {
          language: {
            site: :languages
          }
        },
        :public_version
      ]
      # The admin sitemap (and the serializer's admin fields) render lock info,
      # so only eager-load the locker when the user may administer pages.
      associations.push(:locker) if ability.can?(:index, :alchemy_admin_pages)
      associations
    end
  end

  class PageTreePage < SimpleDelegator
    attr_accessor :folded
    alias_method :folded?, :folded
  end
end
