# frozen_string_literal: true

module Alchemy
  class ResourceFilter
    attr_reader :name

    def initialize(filter, resource_name)
      @filter = filter
      @name = filter[:name]
      @resource_name = resource_name
      @values = filter[:values].presence || []
    end

    def options_for_select
      translated_values.zip(values)
    end

    def values
      if translated?
        @values.map { |v| v[1] }
      else
        @values
      end
    end

    private

    def translated?
      @values.first.is_a?(Array)
    end

    def translated_values
      if translated?
        @values.map { |a| a[0] }
      else
        @values.map { |v| Alchemy.t(v.to_sym, scope: ["filters", @resource_name, @name, "values"]) }
      end
    end
  end
end
