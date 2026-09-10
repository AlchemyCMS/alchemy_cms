module Alchemy
  # Generates an ETag for a page.
  #
  # By default, it uses the page's id and the ids of its published elements.
  # You can customize this by providing your own generator in the configuration.
  class Page::EtagGenerator
    attr_reader :page

    # @param page [Alchemy::Page] The page for which to generate the ETag.
    def initialize(page)
      @page = page
    end

    # @return [Array<Object>]
    # @param args [Array<Object>] Additional arguments that can be used in the ETag generation.
    def call(*args)
      elements_cache_key = published_element_ids
      [page, elements_cache_key, *args]
    end

    private

    # Returns the sorted ids of all currently published elements for use as a
    # cache key. Reads from the page version's in-memory elements association
    # when it has already been populated (e.g. by +Alchemy::PageLoader+) to
    # avoid a redundant database round-trip; falls back to a pluck query when
    # the association has not been loaded.
    def published_element_ids
      version = page.public_version
      return nil unless version

      if version.association(:elements).loaded?
        version.element_repository.visible.map(&:id).sort
      else
        version.elements.published.order(:id).pluck(:id)
      end
    end
  end
end
