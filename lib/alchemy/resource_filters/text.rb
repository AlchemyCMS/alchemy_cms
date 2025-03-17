# frozen_string_literal: true

module Alchemy
  module ResourceFilters
    class Text
      attr_reader :name, :resource_name

      def initialize(filter, resource_name)
        @filter = filter
        @name = filter[:name]
        @resource_name = resource_name
      end

      def to_partial_path
        "alchemy/admin/resources/filters/text"
      end
    end
  end
end
