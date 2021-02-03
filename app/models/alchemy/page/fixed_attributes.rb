# frozen_string_literal: true

module Alchemy
  class Page < BaseRecord
    # = Fixed page attributes
    #
    # Fixed page attributes are not allowed to be changed by the user.
    #
    # Define fixed page attributes on the page layout definition of a page.
    #
    # == Example
    #
    #     # page_layout.yml
    #     - name: Index
    #       unique: true
    #       fixed_attributes:
    #         - public_on: nil
    #         - public_until: nil
    #
    class FixedAttributes
      attr_reader :page

      def initialize(page)
        @page = page
      end

      # All fixed attributes defined on page
      #
      # Aliased as +#all+
      #
      # @return Hash
      #
      def attributes
        @_attributes ||= page.definition.fetch("fixed_attributes", {}).symbolize_keys
      end
      alias_method :all, :attributes

      # True if fixed attributes are defined on page
      #
      # Aliased as +#present?+
      #
      # @return Boolean
      #
      def any?
        attributes.present?
      end
      alias_method :present?, :any?

      # True if given attribute name is defined on page
      #
      # @return Boolean
      #
      def fixed?(name)
        return false if name.nil?

        attributes.key?(name.to_sym)
      end

      # Returns the attribute by key
      #
      def [](name)
        return nil if name.nil?

        attributes[name.to_sym]
      end
    end
  end
end
