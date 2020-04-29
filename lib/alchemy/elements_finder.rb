# frozen_string_literal: true

require "alchemy/logger"

module Alchemy
  # Loads elements from given page
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
    # @option options [Hash] :fallback
    #   Define elements that are loaded from another page if no element was found on given page.
    def initialize(options = {})
      @options = options
    end

    # @param page [Alchemy::Page|String]
    #   The page the elements are loaded from. You can pass a page_layout String or a {Alchemy::Page} object.
    # @return [ActiveRecord::Relation]
    def elements(page:)
      elements = find_elements(page)

      if fallback_required?(elements)
        elements = elements.merge(fallback_elements)
      end

      if options[:reverse]
        elements = elements.reverse_order
      end

      if options[:random]
        elements = elements.reorder(Arel.sql(random_function))
      end

      elements.offset(options[:offset]).limit(options[:count])
    end

    private

    attr_reader :page, :options

    def find_elements(page_or_layout)
      @page = get_page(page_or_layout)
      return Alchemy::Element.none unless page

      if options[:fixed]
        elements = page.fixed_elements
      else
        elements = page.elements
      end

      if options[:only]
        elements = elements.named(options[:only])
      end

      if options[:except]
        elements = elements.excluded(options[:except])
      end

      elements
    end

    def get_page(page_or_layout)
      case page_or_layout
      when Alchemy::Page
        page_or_layout
      when String
        Alchemy::Page.find_by(
          language: Alchemy::Language.current,
          page_layout: page_or_layout,
          restricted: false,
        )
      end
    end

    def fallback_required?(elements)
      options[:fallback] && elements
        .where(Alchemy::Element.table_name => {name: options[:fallback][:for]})
        .none?
    end

    def fallback_elements
      find_elements(options[:fallback][:from])
        .named(options[:fallback][:with] || options[:fallback][:for])
    end

    def random_function
      case ActiveRecord::Base.connection_config[:adapter]
      when "postgresql", "sqlite3"
        "RANDOM()"
      else
        "RAND()"
      end
    end
  end
end
