module Alchemy
  module Admin
    # Creates a live filter for lists of DOM items.
    #
    # The items must have a html +name+ attribute that holds the filterable value.
    #
    # == Example
    #
    # Given a list of items:
    #
    #   <%= render Alchemy::Admin::ListFilter.new('#products .product') %>
    #
    #   <ul id="products">
    #     <li class="product" name="kat litter">Kat Litter</li>
    #     <li class="product" name="milk">Milk</li>
    #   </ul>
    #
    # @param [String] items_selector - A CSS selector string that represents the items to filter
    # @param [String] name_attribute - A name that represents the attribute on the items to get filtered by
    #
    class ListFilter < ViewComponent::Base
      erb_template <<~ERB
        <alchemy-list-filter items-selector="<%= items_selector %>" name-attribute="<%= name_attribute %>">
          <input type="search" class="js_filter_field" />
          <alchemy-icon name="search"></alchemy-icon>
          <button type="reset" class="js_filter_field_clear icon_button">
            <alchemy-icon name="close" size="1x"></alchemy-icon>
          </button>
        </alchemy-list-filter>
      ERB

      def initialize(items_selector, name_attribute: "name")
        @items_selector = items_selector
        @name_attribute = name_attribute
      end

      private

      attr_reader :items_selector, :name_attribute
    end
  end
end
