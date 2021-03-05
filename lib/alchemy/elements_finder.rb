# frozen_string_literal: true

require "alchemy/logger"

module Alchemy
  # Loads elements from given page version.
  #
  # Used by {Alchemy::Page#find_elements} and {Alchemy::ElementsHelper#render_elements} helper.
  #
  # If you need custom element loading logic in your views you can create your own finder class and
  # tell the {Alchemy::ElementsHelper#render_elements} helper or {Alchemy::Page#find_elements}
  # to use that finder instead of this one.
  #
  class ElementsFinder
    # @option options [Array<String>|String] :only
    #   A list of element names to load only.
    # @option options [Array<String>|String] :except
    #   A list of element names not to load.
    # @option options [Boolean] :fixed (false)
    #   Return only fixed elements
    # @option options [Integer] :count
    #   The amount of elements to load
    # @option options [Integer] :offset
    #   The offset to begin loading elements from
    # @option options [Boolean] :random (false)
    #   Randomize the output of elements
    # @option options [Boolean] :reverse (false)
    #   Reverse the load order
    def initialize(options = {})
      @options = options
    end

    # @param page [Alchemy::PageVersion]
    #   The page version the elements are loaded from.
    # @return [Alchemy::ElementsRepository]
    def elements(page_version:)
      elements = find_elements(page_version)

      if options[:reverse]
        elements = elements.reverse
      end

      if options[:random]
        elements = elements.random
      end

      elements.offset(options[:offset]).limit(options[:count])
    end

    private

    attr_reader :options

    def find_elements(page_version)
      return Alchemy::ElementsRepository.none unless page_version

      elements = Alchemy::ElementsRepository.new(page_version.elements.available)
      elements = elements.not_nested
      elements = options[:fixed] ? elements.fixed : elements.unfixed

      if options[:only]
        elements = elements.named(options[:only])
      end

      if options[:except]
        elements = elements.excluded(options[:except])
      end

      elements
    end
  end
end
