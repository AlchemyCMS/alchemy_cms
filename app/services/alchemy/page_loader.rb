# frozen_string_literal: true

module Alchemy
  # Loads a page with its full content tree preloaded, eliminating N+1 queries
  # when rendering or serializing a page's elements and their ingredients.
  #
  # Loads all elements for the requested page version in a single query,
  # populates the in-memory element tree (nested elements at any depth), and
  # dispatches two complementary preload hooks so callers can eliminate further
  # N+1s:
  #
  # 1. +alchemy_ingredient_preloads+ on the ingredient class (STI type).
  #    Called with the collection of that ingredient type's instances.
  #    Implement this on your custom ingredient classes to preload anything
  #    your ingredient needs, including computed associations that have no
  #    +related_object+ (e.g. a custom ingredient that queries a separate
  #    table for its products list).
  #
  # 2. +alchemy_element_preloads+ on the related_object class (the class of
  #    +ingredient.related_object+). This is the existing hook already
  #    implemented by +Alchemy::Picture+ and any class that includes
  #    +Alchemy::RelatableResource+, and continues to work exactly as before.
  #
  # Both hooks receive a de-duplicated array of their respective records
  # gathered from all elements and all nesting depths in one pass.
  #
  # The loaded page version's +element_repository+ is populated in-memory,
  # so subsequent calls to +render_elements+, +el.nested_elements+, and the
  # +ElementsBlockHelper+ all benefit without issuing further queries.
  #
  # @example In a controller
  #   def load_page
  #     @page = Page.find_by(urlname: params[:urlname])
  #     Alchemy::PageLoader.call(page: @page, version: :public_version)
  #     @page
  #   end
  #
  class PageLoader
    VERSIONS = EagerLoading::PAGE_VERSIONS

    # @param page [Alchemy::Page] the page whose element tree should be loaded
    # @param version [Symbol] which version to load — +:public_version+ or
    #   +:draft_version+
    def self.call(page:, version:)
      raise UnsupportedPageVersion unless version.in?(VERSIONS)

      new(page.public_send(version)).call
    end

    # @param page_version [Alchemy::PageVersion, nil]
    #   The page version whose element tree should be loaded. +nil+ is a no-op.
    def initialize(page_version)
      @page_version = page_version
    end

    # Loads the full element tree for the page version and dispatches preload
    # hooks. Returns +nil+ when the page version is nil (e.g. a page that has
    # never been published yet).
    #
    # @return [nil]
    def call
      return unless page_version

      all_elements = load_all_elements
      populate_nested_associations(all_elements)
      preload_ingredients(all_elements.values)

      nil
    end

    private

    attr_reader :page_version

    # Load all elements for the page version in a single query with ingredients
    # and their related_objects eager-loaded, indexed by id for O(1) tree building.
    def load_all_elements
      elements = Element
        .where(page_version_id: page_version.id)
        .includes(ingredients: :related_object)
        .index_by(&:id)

      # Point every element's page_version back to the canonical page_version
      # object held by this loader. ElementsBlockHelper#nested_elements accesses
      # element.page_version.element_repository; if elements were loaded without
      # :page_version, each access fires a fresh query and gets a new object
      # with its own empty element_repository, defeating the entire preload.
      # Overriding the association here ensures they all share the single
      # page_version instance whose elements association we populate next.
      elements.each_value do |element|
        element.association(:page_version).target = page_version
        element.association(:page_version).loaded!
      end

      elements
    end

    # Wire up the all_nested_elements association on every element in memory,
    # populate the page_version's flat collection so ElementsFinder and
    # ElementsBlockHelper#nested_elements read from the in-memory cache without
    # re-querying, and also warm the page-level element associations
    # (page.elements, page.all_elements) when they share the same in-memory
    # page object — which allows the JSON API serializer to serve elements
    # from memory rather than issuing a separate query through the
    # has_many :through.
    def populate_nested_associations(elements_by_id)
      elements_by_parent = elements_by_id.values.group_by(&:parent_element_id)

      elements_by_id.each_value do |element|
        children = (elements_by_parent[element.id] || []).sort_by { _1.position.to_i }
        element.association(:all_nested_elements).target = children
        element.association(:all_nested_elements).loaded!
      end

      all_flat = elements_by_id.values.sort_by { _1.position.to_i }

      page_version.association(:elements).target = all_flat
      page_version.association(:elements).loaded!

      # page_version belongs_to :page with inverse_of, so .page is already the
      # same in-memory object. Populate the has_many :through associations on
      # it so serializers and view helpers that access page.elements or
      # page.all_elements also read from the in-memory collection.
      page = page_version.page
      if page
        page.association(:elements).target = all_flat
        page.association(:elements).loaded!
        page.association(:all_elements).target = all_flat
        page.association(:all_elements).loaded!
      end
    end

    # Gather all ingredients from every element, group by ingredient class and
    # by related_object class, then call the two preload hooks on each group.
    def preload_ingredients(elements)
      by_ingredient_class = Hash.new { |h, k| h[k] = [] }
      by_related_class = Hash.new { |h, k| h[k] = {} }

      elements.each do |element|
        element.ingredients.each do |ingredient|
          by_ingredient_class[ingredient.class] << ingredient

          obj = ingredient.related_object
          by_related_class[obj.class][obj.id] = obj if obj
        end
      end

      # Hook 1: per ingredient class — lets ingredient types preload whatever
      # they need, including computed non-related_object data.
      by_ingredient_class.each do |klass, ingredients|
        if klass.respond_to?(:alchemy_ingredient_preloads)
          klass.alchemy_ingredient_preloads(ingredients)
        end
      end

      # Hook 2: per related_object class — the existing hook used by Picture
      # (thumbnail preloading) and any class including RelatableResource.
      by_related_class.each do |klass, objects_by_id|
        if klass.respond_to?(:alchemy_element_preloads)
          klass.alchemy_element_preloads(objects_by_id.values)
        end
      end
    end
  end
end
