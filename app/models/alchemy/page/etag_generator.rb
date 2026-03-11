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
      elements_cache_key = page.public_version&.elements&.published&.order(:id)&.pluck(:id)
      [page, elements_cache_key, *args]
    end
  end
end
